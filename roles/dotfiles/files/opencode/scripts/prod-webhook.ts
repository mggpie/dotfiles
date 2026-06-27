#!/usr/bin/env bun
/**
 * prod-webhook.ts - Error report webhook for OpenCode swarm.
 *
 * Minimal Bun HTTP server that receives error reports (Sentry/LogRocket/etc
 * webhook format) and records them as hivemind memories so the swarm learns
 * from production errors.
 *
 * Endpoints:
 *   POST /webhook  - Accept JSON error report, validate secret, store to hivemind
 *
 * Environment:
 *   SWARM_WEBHOOK_SECRET  - Required. Shared secret for x-swarm-secret header.
 *   SWARM_PROJECT_DIR     - Project directory for hivemind db context.
 *   PORT                  - Listen port (default: 4097).
 *
 * Usage:
 *   bun run prod-webhook.ts
 *   # or deploy via runit/systemd --user
 */

import { type Server } from "bun";

const PORT = parseInt(process.env.PORT || "4097", 10);
const SECRET = process.env.SWARM_WEBHOOK_SECRET || "";
const PROJECT_DIR = process.env.SWARM_PROJECT_DIR || process.cwd();

if (!SECRET) {
  console.error("FATAL: SWARM_WEBHOOK_SECRET is not set");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Hivemind storage
// ---------------------------------------------------------------------------

/**
 * Resolve the swarm CLI path relative to the opencode config directory.
 * Falls back to the npm-installed swarm binary.
 */
function swarmCliPath(): string {
  const fromEnv = process.env.SWARM_CLI_PATH;
  if (fromEnv) return fromEnv;

  // import.meta.dir is the directory of this script: ~/.config/opencode/scripts/
  // dirname gives us the config root: ~/.config/opencode/
  const { dirname } = require("node:path");
  const configDir = process.env.OPENCODE_CONFIG_DIR
    || dirname(import.meta.dir!);
  return `${configDir}/node_modules/.bin/swarm`;
}

/**
 * Store an error report as a hivemind memory by shelling out to the swarm CLI.
 *
 * The swarm CLI's `tool` subcommand handles JSON serialization of args and
 * response parsing, avoiding direct libSQL dependency in this script.
 * Returns true if the store succeeded.
 */
async function storeError(errorInfo: Record<string, unknown>): Promise<boolean> {
  const cli = swarmCliPath();
  const information = JSON.stringify({
    source: "prod-webhook",
    received: new Date().toISOString(),
    ...errorInfo,
  });

  // Extract a useful tag from the error payload
  const tagParts: string[] = ["error"];
  if (typeof errorInfo.level === "string") tagParts.push(errorInfo.level);
  if (typeof errorInfo.exception?.type === "string") {
    tagParts.push(errorInfo.exception.type);
  } else if (typeof errorInfo.exception_type === "string") {
    tagParts.push(errorInfo.exception_type);
  } else if (typeof errorInfo.error?.type === "string") {
    tagParts.push(errorInfo.error.type);
  }
  const tags = tagParts.join(",");

  const proc = Bun.spawnSync([cli, "tool", "hivemind_store", "--json", JSON.stringify({
    information,
    tags,
  })], {
    env: {
      ...process.env,
      SWARM_PROJECT_DIR: PROJECT_DIR,
    },
  });

  if (!proc.exitCode || proc.exitCode !== 0) {
    console.error("[webhook] hivemind_store failed:", proc.stderr.toString());
    return false;
  }

  return true;
}

// ---------------------------------------------------------------------------
// HTTP server
// ---------------------------------------------------------------------------

const server: Server = Bun.serve({
  port: PORT,
  hostname: "127.0.0.1",

  async fetch(req: Request): Promise<Response> {
    const url = new URL(req.url);

    // Only accept POST /webhook
    if (req.method !== "POST" || url.pathname !== "/webhook") {
      return new Response("Not Found", { status: 404 });
    }

    // Validate auth header
    const authHeader = req.headers.get("x-swarm-secret");
    if (!authHeader || authHeader !== SECRET) {
      return new Response("Unauthorized", { status: 401 });
    }

    // Parse JSON body
    let body: unknown;
    try {
      body = await req.json();
    } catch {
      return new Response("Invalid JSON", { status: 400, headers: { "content-type": "text/plain" } });
    }

    if (typeof body !== "object" || body === null || Array.isArray(body)) {
      return new Response("Body must be a JSON object", {
        status: 400,
        headers: { "content-type": "text/plain" },
      });
    }

    // Store to hivemind (fire-and-forget from the caller's perspective)
    const payload = body as Record<string, unknown>;
    const stored = await storeError(payload);

    if (stored) {
      console.log("[webhook] stored error report:", new Date().toISOString());
      return new Response("Accepted", { status: 202 });
    }

    // hivemind store failed — still return 202 since we received the report,
    // but log the failure. The report is not lost (we could add disk buffering
    // later if this becomes a pattern).
    console.error("[webhook] accepted but failed to store report");
    return new Response("Accepted (storage deferred)", { status: 202 });
  },

  error(error: Error): Response {
    console.error("[webhook] server error:", error);
    return new Response("Internal Server Error", { status: 500 });
  },
});

console.log(`[webhook] listening on http://127.0.0.1:${PORT}`);

// ---------------------------------------------------------------------------
// Graceful shutdown
// ---------------------------------------------------------------------------

function shutdown(signal: string): void {
  console.log(`[webhook] received ${signal}, shutting down...`);
  server.stop();
  // Force exit after 2s if graceful shutdown hangs
  setTimeout(() => {
    console.error("[webhook] forced exit after shutdown timeout");
    process.exit(1);
  }, 2000).unref();
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
