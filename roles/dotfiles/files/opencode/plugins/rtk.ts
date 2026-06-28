import type { Plugin } from "@opencode-ai/plugin"
import { readFileSync, rmSync } from "node:fs"
import { tmpdir } from "node:os"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.
//
// Uses PTY API (input.client.pty.create) instead of BunShell for OpenChamber
// (GUI/VSCode) compatibility. OpenChamber's hardened-runtime sandbox blocks
// ALL process spawning from plugins. The OpenCode SERVER creates the PTY
// process, not the plugin. Output goes to a temp file read via fs.

async function ptyExec(
  client: any,
  command: string,
  cwd: string,
): Promise<string> {
  const tmpFile = `${tmpdir()}/rtk-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
  try {
    const escapedTmp = tmpFile.replace(/'/g, "'\\''")
    const shellCmd = `${command} > '${escapedTmp}' 2>&1`

    const ptyResult = await client.pty.create({
      body: {
        command: "/bin/bash",
        args: ["-c", shellCmd],
        cwd,
        env: {
          PATH: `/home/me/.nix-profile/bin:/home/me/.local/bin:/usr/bin:/usr/local/bin:${process.env.PATH || ""}`,
        },
      },
    })

    const ptyInfo: any = ptyResult?.data || ptyResult
    const ptyId: string | undefined = ptyInfo?.id
    if (!ptyId) return ""

    // Poll until PTY exits
    const maxWait = 10000
    const pollInterval = 200
    let waited = 0
    let ptyStatus = "running"

    while (ptyStatus === "running" && waited < maxWait) {
      await new Promise(resolve => setTimeout(resolve, pollInterval))
      waited += pollInterval
      try {
        const info = await client.pty.get({ path: { id: ptyId } })
        const infoData: any = info?.data || info
        ptyStatus = infoData?.status || "running"
      } catch {
        // assume still running on error
      }
    }

    // Clean up PTY
    try { await client.pty.remove({ path: { id: ptyId } }) } catch {}

    // Read output
    try { return readFileSync(tmpFile, "utf-8").trim() } catch { return "" }
  } finally {
    try { rmSync(tmpFile, { force: true }) } catch {}
  }
}

export const RtkOpenCodePlugin: Plugin = async (input) => {
  const client = input.client
  const directory = input.directory

  // Check if rtk binary is available via PTY
  try {
    const output = await ptyExec(client, "which rtk", directory)
    if (!output.startsWith("/")) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return {}
    }
  } catch {
    console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
    return {}
  }

  return {
    "tool.execute.before": async (hookInput, output) => {
      const tool = String(hookInput?.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const args = output?.args
      if (!args || typeof args !== "object") return

      const command = (args as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      try {
        const escapedCmd = command.replace(/'/g, "'\\''")
        const result = await ptyExec(client, `rtk rewrite '${escapedCmd}'`, directory)
        if (result && result !== command) {
          ;(args as Record<string, unknown>).command = result
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    },
  }
}
