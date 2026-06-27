---
description: Show token usage and cost per swarm session.
---

# /costs

$ARGUMENTS

Reads cost records from `~/.config/opencode/costs/<session-id>.json` and
prints a summary per session.

## Pricing

Token costs for each model used in this setup:

| Model | Input ($/1M) | Output ($/1M) |
|---|---:|---:|
| deepseek-v4-pro | $0.435 | $0.87 |
| deepseek-v4-flash | $0.09 | $0.18 |
| kimi-k2-thinking | $0.60 | $2.50 |
| glm-5.2 | $1.20 | $4.10 |
| minimax-m2.7 | $0.15 | $0.90 |

## Usage

Without arguments — show costs for the most recent session:

```
/costs
```

For a specific session:

```
/costs <session-id>
```

## Output

Example:

```
Last swarm: 5 agents, 142K tokens, $0.18

Session: swarm-abcd1234
  deepseek-v4-pro         12K in / 8K out           $0.012
  deepseek-v4-flash       80K in / 42K out          $0.015
  Total:                  92K in / 50K out          $0.027
```

Records are written by `scripts/cost-tracker.ts`, which hooks into API
responses and logs every agent call. Run it standalone to aggregate:

```bash
bun run ~/.config/opencode/scripts/cost-tracker.ts summary <session-id>
```

## Files

- `~/.config/opencode/costs/<session-id>.json` — per-session cost records
- `scripts/cost-tracker.ts` — recording and aggregation logic
