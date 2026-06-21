# Venture pipeline (Psyche → BizDev → Code)

Loaded on demand when reasoning about the pre-code layers. The same swarm engine
(orchestration, hive, swarmmail, hivemind, learning loop, adversary) drives all
three layers — only the agents, models, and output artifacts change.

## The three layers

| Layer | Command | Question | Output | Adversary |
|---|---|---|---|---|
| 0 · Profile | `/profile` | "Who am I — what's my founder-fit?" | `profile/founder-fit.md` | — |
| 3 · Psyche | `/ideate` | "What fits ME and exploits my unfair advantage?" | `0-opportunity.md` | `psyche-critic` (fit) |
| 2 · BizDev | `/validate` | "Will anyone actually pay? Kill it cheaply." | `1-validation.md` → `2-plan.md` | `biz-demon` (market) |
| 1 · Code | `/swarm` | "Build the accepted thing." | code + PR | `demon` (technical) |

**Layer 0 (Profile)** ingests the founder's FULL profile bundle — it lives in their
PARA-organized Desktop at `~/Desktop/3-Resources/profile/jakub/` (a rich RAG bundle:
knowledge-base + timeline + canonical, read directly as the source of truth) — and
distills it into `~/Desktop/3-Resources/profile/founder-fit.md` (unfair
advantages, energy map, anti-fit, distribution). `/ideate` reads BOTH the bundle and
this lens. The bundle is psychological; founder-fit.md is the business translation.

**Where artifacts live (PARA-native):** ideas incubate in
`~/Desktop/1-Projects/_ideas/<slug>/` (a project-level incubator, peer to real
projects). On a GO verdict the idea **graduates** to its own real project
`~/Desktop/1-Projects/<slug>/`, where `/swarm` builds it. The pipeline is a
workflow over PARA, not a separate folder tree.

**Human gate between every layer.** An artifact must be reviewed and accepted
before the next layer runs. Artifacts + hivemind ARE the handoff contract.

## Two death-modes, two adversaries

- `psyche-critic` kills ideas with **no founder-market fit** — anyone could build
  it, it fights your nature, no moat from YOUR edge.
- `biz-demon` kills ideas with **no business** — no market, CAC > LTV, COGS eats
  margin, incumbent crushes it, churn, founder burnout.
- `demon` (code layer) kills **broken implementations** — edge cases, races, OWASP.

An idea must survive all three to become a shipped, paid product.

## Anti-sycophancy (the #1 risk)

LLMs flatter by default. Countermeasures baked into the prompts:
- Adversaries default to "this FAILS"; a pass requires a genuine failed kill.
- Every attack must cite **real data** (researchers have web access) — not stale
  general knowledge.
- Quantified gates: CFO must show unit economics; **COGS ≥ price → `needs_changes`**.
- Expected high kill-rate: if adversaries pass ideas easily, they're being soft →
  use `--brutal` on `/validate`.

## Models (cost-aware, diverse — all Chinese frontier, zero US-frontier)

DeepSeek V4 (coordinators + researchers, cheapest) · Kimi K2 Thinking
(analysts/strategy) · MiniMax M2.7 (adversaries — different family = catches different
blind spots). All a fraction of US-frontier prices. Swap any to a stronger model
(e.g. GLM 5.2) in the agent file for a high-stakes venture.

## Why this exists

The code swarm builds *defined* problems perfectly ("write Stripe webhooks") but
won't invent the business or tell you nobody will pay. These layers move the
adversarial, learning-aware swarm UPSTREAM — so a bad idea dies in minutes in the
console, not after months of building.
