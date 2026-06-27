/**
 * Cost Tracker — records API token usage and computes costs per swarm session.
 *
 * Hooks into OpenRouter-compatible API responses from agent calls and writes
 * cost records to ~/.config/opencode/costs/<session-id>.json.
 *
 * CLI usage:
 *   bun run cost-tracker.ts record <session-id> <model> <input-tokens> <output-tokens>
 *   bun run cost-tracker.ts summary [<session-id>]
 *   bun run cost-tracker.ts list
 */

import { existsSync, mkdirSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

// =============================================================================
// Pricing table ($ per 1M tokens)
// =============================================================================

const PRICING: Record<string, { input: number; output: number }> = {
  "deepseek-v4-pro":       { input: 0.435, output: 0.87 },
  "deepseek-v4-flash":     { input: 0.09,  output: 0.18 },
  "kimi-k2-thinking":      { input: 0.60,  output: 2.50 },
  "glm-5.2":               { input: 1.20,  output: 4.10 },
  "minimax-m2.7":          { input: 0.15,  output: 0.90 },
};

const MODEL_ALIASES: Record<string, string> = {
  "deepseek/deepseek-v4-pro":       "deepseek-v4-pro",
  "deepseek/deepseek-v4-flash":     "deepseek-v4-flash",
  "deepseek/deepseek-chat":         "deepseek-v4-flash", // generic fallback
  "openrouter/moonshotai/kimi-k2-thinking": "kimi-k2-thinking",
  "openrouter/z-ai/glm-5.2":                "glm-5.2",
  "openrouter/minimax/minimax-m2.7":        "minimax-m2.7",
  "moonshotai/kimi-k2-thinking":    "kimi-k2-thinking",
  "z-ai/glm-5.2":                  "glm-5.2",
  "minimax/minimax-m2.7":          "minimax-m2.7",
};

// =============================================================================
// File layout
// =============================================================================

const COSTS_DIR = join(homedir(), ".config", "opencode", "costs");

/** Single API call record */
interface CostRecord {
  timestamp: string;
  model: string;
  inputTokens: number;
  outputTokens: number;
  cost: number;
}

/** Per-session aggregated data */
interface SessionCosts {
  sessionId: string;
  agents: number;
  models: Record<string, {
    inputTokens: number;
    outputTokens: number;
    cost: number;
  }>;
  totalCost: number;
  totalInputTokens: number;
  totalOutputTokens: number;
  calls: CostRecord[];
}

// =============================================================================
// Helpers
// =============================================================================

function ensureDir(dir: string): void {
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }
}

/**
 * Normalize a model string to its short key.
 * Strips provider prefix and matches aliases.
 */
function normalizeModel(model: string): string {
  const trimmed = model.trim();
  if (PRICING[trimmed]) return trimmed;
  if (MODEL_ALIASES[trimmed]) return MODEL_ALIASES[trimmed];

  // Try to match just the short name from a full path
  const parts = trimmed.split("/");
  const shortName = parts[parts.length - 1];
  if (PRICING[shortName]) return shortName;

  // Fallback — return as-is with zero pricing
  return trimmed;
}

/**
 * Compute cost for a model given token counts.
 */
function computeCost(model: string, inputTokens: number, outputTokens: number): number {
  const key = normalizeModel(model);
  const pricing = PRICING[key];
  if (!pricing) return 0;
  return (inputTokens / 1_000_000) * pricing.input +
         (outputTokens / 1_000_000) * pricing.output;
}

/**
 * Round to 6 decimal places (fraction of a cent).
 */
function roundCost(cost: number): number {
  return Math.round(cost * 1_000_000) / 1_000_000;
}

// =============================================================================
// Session file helpers
// =============================================================================

/**
 * Sanitize session ID to prevent path traversal.
 * Only allows alphanumeric, hyphens, underscores, and dots.
 */
function sanitizeSessionId(sessionId: string): string {
  return sessionId.replace(/[^a-zA-Z0-9._-]/g, "_");
}

function sessionPath(sessionId: string): string {
  const safe = sanitizeSessionId(sessionId);
  return join(COSTS_DIR, `${safe}.json`);
}

function loadSession(sessionId: string): SessionCosts {
  const path = sessionPath(sessionId);
  if (!existsSync(path)) {
    return {
      sessionId,
      agents: 0,
      models: {},
      totalCost: 0,
      totalInputTokens: 0,
      totalOutputTokens: 0,
      calls: [],
    };
  }
  try {
    const raw = readFileSync(path, "utf-8");
    return JSON.parse(raw) as SessionCosts;
  } catch {
    return {
      sessionId,
      agents: 0,
      models: {},
      totalCost: 0,
      totalInputTokens: 0,
      totalOutputTokens: 0,
      calls: [],
    };
  }
}

function saveSession(session: SessionCosts): void {
  ensureDir(COSTS_DIR);
  const path = sessionPath(session.sessionId);
  writeFileSync(path, JSON.stringify(session, null, 2), "utf-8");
}

// =============================================================================
// Core operations
// =============================================================================

/**
 * Record a single API call for a session.
 * Appends to the session file, creating it if needed.
 *
 * @param sessionId - Swarm session ID (or OPENCODE_SESSION_ID)
 * @param model - Model identifier (e.g. "deepseek/deepseek-v4-flash")
 * @param inputTokens - Input tokens consumed
 * @param outputTokens - Output tokens generated
 */
function recordCall(
  sessionId: string,
  model: string,
  inputTokens: number,
  outputTokens: number,
): SessionCosts {
  const session = loadSession(sessionId);
  const cost = roundCost(computeCost(model, inputTokens, outputTokens));
  const normalized = normalizeModel(model);

  const record: CostRecord = {
    timestamp: new Date().toISOString(),
    model: normalized,
    inputTokens,
    outputTokens,
    cost,
  };

  session.calls.push(record);

  if (!session.models[normalized]) {
    session.models[normalized] = { inputTokens: 0, outputTokens: 0, cost: 0 };
  }

  session.models[normalized].inputTokens += inputTokens;
  session.models[normalized].outputTokens += outputTokens;
  session.models[normalized].cost = roundCost(session.models[normalized].cost + cost);
  session.totalInputTokens += inputTokens;
  session.totalOutputTokens += outputTokens;
  session.totalCost = roundCost(session.totalCost + cost);

  // Count unique agents by deduplicating the first call per model burst
  // (a reasonable heuristic without explicit agent name tracking)
  const uniqueAgents = new Set(session.calls.map(c => c.model));
  session.agents = uniqueAgents.size;

  saveSession(session);
  return session;
}

/**
 * Compute summary for a session.
 * Returns the loaded session data or null if no records exist.
 */
function getSummary(sessionId: string): SessionCosts | null {
  const session = loadSession(sessionId);
  if (session.calls.length === 0) return null;
  return session;
}

/**
 * List all tracked sessions with their summaries.
 */
function listSessions(): SessionCosts[] {
  ensureDir(COSTS_DIR);
  const files = readdirSync(COSTS_DIR).filter(f => f.endsWith(".json"));
  const sessions: SessionCosts[] = [];
  for (const file of files) {
    const sessionId = file.replace(/\.json$/, "");
    const summary = getSummary(sessionId);
    if (summary) sessions.push(summary);
  }
  // Most recent first
  sessions.sort((a, b) => {
    const aLast = a.calls[a.calls.length - 1]?.timestamp || "";
    const bLast = b.calls[b.calls.length - 1]?.timestamp || "";
    return bLast.localeCompare(aLast);
  });
  return sessions;
}

/**
 * Format a session summary as a human-readable string.
 */
function formatSession(session: SessionCosts): string {
  const lines: string[] = [];
  const tokensIn = session.totalInputTokens.toLocaleString();
  const tokensOut = session.totalOutputTokens.toLocaleString();
  const totalTokens = (session.totalInputTokens + session.totalOutputTokens).toLocaleString();

  lines.push(`Session: ${session.sessionId}`);
  lines.push(`  Agents: ${session.agents}`);

  for (const [model, data] of Object.entries(session.models)) {
    const costStr = `$${data.cost.toFixed(4)}`;
    lines.push(
      `  ${model.padEnd(25)} ${String(data.inputTokens).padStart(6)} in / ${String(data.outputTokens).padStart(6)} out    ${costStr}`,
    );
  }

  lines.push(`  Total: ${tokensIn} in / ${tokensOut} out (${totalTokens} tokens)`);
  lines.push(`  Cost:  $${session.totalCost.toFixed(4)}`);

  return lines.join("\n");
}

// =============================================================================
// CLI entrypoint
// =============================================================================

function printHelp(): void {
  console.log(`Usage:
  bun run cost-tracker.ts record <session-id> <model> <input-tokens> <output-tokens>
  bun run cost-tracker.ts summary [<session-id>]
  bun run cost-tracker.ts list

Examples:
  bun run cost-tracker.ts record swarm-abc123 deepseek/deepseek-v4-flash 15000 3200
  bun run cost-tracker.ts summary swarm-abc123
  bun run cost-tracker.ts list
`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const command = args[0]?.toLowerCase();

  // If SWARM_SESSION_ID or OPENCODE_SESSION_ID is set, use it as default
  const envSession = process.env.SWARM_SESSION_ID || process.env.OPENCODE_SESSION_ID;

  switch (command) {
    case "record": {
      const [, sessionId, model, inputStr, outputStr] = args;
      if (!sessionId || !model || !inputStr || !outputStr) {
        console.error("Usage: cost-tracker.ts record <session-id> <model> <input-tokens> <output-tokens>");
        process.exit(1);
      }
      const inputTokens = parseInt(inputStr, 10);
      const outputTokens = parseInt(outputStr, 10);
      if (isNaN(inputTokens) || isNaN(outputTokens)) {
        console.error("Token counts must be numbers");
        process.exit(1);
      }
      const session = recordCall(sessionId, model, inputTokens, outputTokens);
      console.log(`Recorded: ${model} ${inputTokens} in / ${outputTokens} out ($${session.totalCost.toFixed(4)} total)`);
      break;
    }

    case "summary": {
      const sessionId = args[1] || envSession;
      if (!sessionId) {
        console.error("No session ID provided and SWARM_SESSION_ID / OPENCODE_SESSION_ID not set");
        console.log("");
        printHelp();
        process.exit(1);
      }
      const session = getSummary(sessionId);
      if (!session) {
        console.log(`No cost records found for session: ${sessionId}`);
        process.exit(0);
      }
      console.log(formatSession(session));

      // One-liner for quick glance
      const totalTokens = (session.totalInputTokens + session.totalOutputTokens).toLocaleString();
      console.log(`\nLast swarm: ${session.agents} agents, ${totalTokens} tokens, $${session.totalCost.toFixed(2)}`);
      break;
    }

    case "list": {
      const sessions = listSessions();
      if (sessions.length === 0) {
        console.log("No cost records found.");
        process.exit(0);
      }
      for (const session of sessions) {
        const totalTokens = (session.totalInputTokens + session.totalOutputTokens).toLocaleString();
        console.log(`${session.sessionId.padEnd(30)} ${String(session.agents).padStart(3)} agents  ${totalTokens.padStart(8)} tokens  $${session.totalCost.toFixed(4)}`);
      }
      break;
    }

    case "help":
    case "--help":
    case "-h":
      printHelp();
      break;

    default: {
      // No command — show summary for env session or last session
      if (envSession) {
        const session = getSummary(envSession);
        if (session) {
          console.log(formatSession(session));
          const totalTokens = (session.totalInputTokens + session.totalOutputTokens).toLocaleString();
          console.log(`\nLast swarm: ${session.agents} agents, ${totalTokens} tokens, $${session.totalCost.toFixed(2)}`);
          break;
        }
      }
      // Fallback: list all sessions
      const sessions = listSessions();
      if (sessions.length === 0) {
        console.log("No cost records found.");
        break;
      }
      const latest = sessions[0];
      console.log(formatSession(latest));
      const totalTokens = (latest.totalInputTokens + latest.totalOutputTokens).toLocaleString();
      console.log(`\nLast swarm: ${latest.agents} agents, ${totalTokens} tokens, $${latest.totalCost.toFixed(2)}`);
    }
  }
}

main().catch(err => {
  console.error("cost-tracker error:", err);
  process.exit(1);
});
