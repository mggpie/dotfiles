# 🐝 OpenCode Swarm — complete guide

Multi-agent system for **ideating, validating, and building** products/SaaS in
**OpenCode 1.17.7 + OpenChamber** (GUI) on Void Linux workstation.

> **One sentence:** expensive model **thinks and evaluates**, cheap models **execute**,
> and a hard **quality gate + memory** ensure cheap models deliver good results.

> **Three layers:** `/ideate` (which idea fits me?) → `/validate` (will anyone pay
> for it?) → `/swarm` (build it). Same engine, different building blocks. Human
> gate between layers. Before them, **Layer 0** (`/profile`) pulls your
> **full profile** and distills it into a founder-fit lens.

---

## 📖 Table of Contents

1. [Why This Exists](#-why-this-exists)
2. [Pipeline: From Idea to Code (3 Layers)](#-pipeline-from-idea-to-code-3-layers)
3. [How It Works — Mental Model](#-how-it-works--mental-model)
4. [Architecture — What It's Made Of](#-architecture--what-its-made-of)
5. [Agents (25) — Who's Who](#-agents-25--whos-who)
6. [Model Selection — and Why](#-model-selection--and-why)
7. [/swarm Flow Step by Step](#-swarm-flow-step-by-step)
8. [Quality Gate](#-quality-gate)
9. [Memory and Learning](#-memory-and-learning)
10. [Commands](#-commands)
11. [Tools (Engine)](#-tools-engine)
12. [Skills (Knowledge on Demand)](#-skills-knowledge-on-demand)
13. [Knowledge Files](#-knowledge-files)
14. [File Structure](#-file-structure)
15. [Git / GitHub (Configured)](#-git--github-configured)
16. [Recipes — Common Scenarios](#-recipes--common-scenarios)
17. [Diagnostics](#-diagnostics)
18. [What NOT to Do](#-what-not-to-do)
19. [Glossary](#-glossary)

---

## 🎯 Why This Exists

**Problem.** A single AI model writing an entire SaaS has three flaws:
- **Expensive** if powerful — or **weak** if cheap.
- Loses context on large tasks (one thread = one context window).
- Nobody reviews its work except you.

**Thesis of this setup.** Separate **thinking** from **execution**:
- Zero expensive US models (no Opus/GPT). Only cheap Chinese models — but diversify
  the review gate: DeepSeek workers, Kimi reviewer, GLM adversary (different families =
  different blind spots).
- Cheap models (DeepSeek V4) do the actual work — but **on max thinking** and
  on a **narrow task**. A worker doesn't need to understand the whole repo, just its piece.
- **Quality gate** (review + adversary + bug scanner) catches what the cheap
  model misses.
- **Cross-session memory** means the system **learns** — subsequent tasks are
  better, because it knows past decisions and mistakes.

**Result.** Cost of expensive model only where it pays off; quality despite cheap
executors; worker isolation (no conflicts); and a system that gets smarter over time.

---

## 🧭 Pipeline: From Idea to Code (3 Layers)

Code-swarm is great at building a **defined** problem ("write Stripe webhooks"), but
it won't come up with a business for you or tell you that **nobody will pay for it**.
So the same engine (orchestration, hive, swarmmail, hivemind, learning loop, adversary)
has been extended **upward** — to ideas and validation. Three layers, sequentially,
with a **human gate** between each:

```  LAYER 0 (Profile)
  /profile  →  profile/founder-fit.md      (pulls your ENTIRE PARA bundle)
       │
       ▼  feeds into ↓  LAYER 3 (Psyche)        LAYER 2 (BizDev)         LAYER 1 (Code)
  /ideate              →    /validate             →    /swarm   (pre-existing)
  "which idea fits            "will anyone pay            "build the accepted
   me and my unfair           for it? kill or              wedge"
   advantage?"               sharpen"
       │                          │                           │
       ▼                          ▼                           ▼
  0-opportunity.md   →      1-validation.md      →      2-plan.md  →  code + PR
       │                          │                           │
       └── You accept ────────────┴── You accept ─────────────┘
```

**Why separate layers instead of one mega-swarm:** clean roles (coordinator doesn't
bloat), different models per layer (cost), and — key — **you approve the
transition**. An idea must pass your accept before moving forward. Artifact (`.md`) +
hivemind = handoff. Each layer feeds memory → future ventures inherit
what worked (and what killed previous ideas).

### Three Death Modes, Three Adversaries

An idea must survive **three different adversaries** to become a paid product:

| Layer | Adversary | Kills the idea when… |
|---|---|---|
| Psyche | `psyche-critic` | **no founder-fit** — anyone could build it, fights your nature, no moat from **your** edge |
| BizDev | `biz-demon` | **no business** — no market, CAC > LTV, COGS eats margin, incumbent crushes, churn, founder burnout |
| Code | `demon` | **bad implementation** — edge cases, race conditions, OWASP |

### Trap: AI is a Yes-Man
Deliberately built-in counters (in adversary prompts): default stance is "it **will fail**"
(pass requires a real, failed attempt to kill it); each attack must cite **real data**
(researchers have web access), not general knowledge from a year ago; **hard gate**: if
COGS ≥ price → `needs_changes`. Expected high kill-rate — if the adversary easily
passes things through, it's too soft → `/validate --brutal`.

### Layer 0: Your Profile (Before Psyche)
Your **full profile** lives in your **PARA** system — the pipeline reads it **directly**
(no copy, no symlink):
`~/Desktop/3-Resources/profile/jakub/` — a rich RAG bundle
(`knowledge-base.md` → `timeline.md` → `canonical.md`). This is the source of truth.

The **`/profile`** command (layer 0) pulls the **entire** bundle and distills it into
`~/Desktop/3-Resources/profile/founder-fit.md` — a business lens: unfair
advantages, energy map, anti-fit, distribution channels, productizable assets.
It only asks about real business gaps (channels, what burns you out in *running*
a business) — the rest comes from the profile. `/ideate` then reads **both the bundle and founder-fit.md**.

The bundle is psychological; `founder-fit.md` is its **business translation**.
The pipeline never copies sensitive details into artifacts — it translates them into
business signals (values like financial autonomy / peace / low people-overhead
→ which business models are **excluded**). Founder churn kills more startups than
bad markets — that's why anti-fit is critical. It's founder-market-fit, not therapy.

Run once: `/profile`. Refresh when your life situation changes.

### Founder-Fit Evolution

After `/validate` returns a `GO` verdict, the system auto-appends to `profile/founder-fit.md` what worked for this idea: which strengths were confirmed, what new distribution channels were discovered, what it says about your founder-market-fit. Founder-fit evolves with each validation — it's not a static snapshot.

---

## 🧠 How It Works — Mental Model

**Brain vs hands.** The coordinator is the brain: orchestrates, **never writes code**.
Workers are the hands: get a narrow task in a one-shot context, do it, disappear.

```
            ┌──────────────────────────────────────────────┐
   YOU ────▶│  COORDINATOR (brain, DeepSeek V4 Pro · max)   │
  /swarm    │  • asks scope   • decomposes into subtasks    │
            │  • spawns       • monitors    • decides       │
            │  • NEVER edits code                           │
            └───────────────┬──────────────────────────────┘
                            │ spawns parallel/sequential
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
  ┌───────────┐       ┌───────────┐       ┌───────────┐
  │ WORKER A  │       │ WORKER B  │       │ WORKER C  │   ← one-shot context
  │ reserves  │       │ reserves  │       │ reserves  │   ← swarmmail_reserve
  │ files,    │       │ files,    │       │ files,    │   ← no conflicts
  │ writes,   │       │ writes,   │       │ writes,   │
  │ tests     │       │ tests     │       │ tests     │
  └─────┬─────┘       └─────┬─────┘       └─────┬─────┘
        └───────────────────┼───────────────────┘
                            ▼
            ┌──────────────────────────────────────────────┐
            │  QUALITY GATE (after EACH worker)             │
            │  reviewer (Kimi) + demon (GLM) + UBS scan     │
            │  approved? → proceed   needs_changes? → retry │
            └───────────────┬──────────────────────────────┘
                            ▼
            ┌──────────────────────────────────────────────┐
            │  SHIPPER → typecheck + lint + tests + UBS     │
            │  → hive_sync (save to git)                    │
            │  → learning loop (remember what worked)       │
            └──────────────────────────────────────────────┘
```

**Why workers have one-shot context?** Because parallel work can't
clog a single context window. Each worker gets a clean, narrow context →
cheaper, faster, less error-prone. The coordinator keeps a clean, long-lived
context for orchestration only.

---

## 🏗️ Architecture — What It's Made Of

Five layers. Everything lives in `~/.config/opencode/`.

| Layer | What it is | Files / mechanism |
|---|---|---|
| **1. Orchestration** | Coordinator + `/swarm` flow | `command/swarm.md`, `AGENTS.md` |
| **2. Agents** | 16 specialized roles | `agent/*.md` |
| **3. Engine (tools)** | Swarm plugin exposes tools that agents use | `plugin/swarm.ts` → CLI `swarm` |
| **4. Quality gate** | Review + adversary + bug scanner | reviewer/demon + UBS |
| **5. Memory** | Cross-session learning | hivemind (Ollama), learning loop, CASS |
| **6. CI/CD** | GitHub Actions: ansible-lint on PR, molecule on merge to main | `.github/workflows/swarm.yml` |

**Key insight:** all the "super features" (epics, file reservations, semantic
memory, adversarial review, learning loop, worktrees) are **native tools of the
swarm plugin 0.63.2** — no need to write them. The work was in the agents,
commands, and rules (`AGENTS.md`) that **use** these tools.

**Tool families** (the plugin exposes them to agents):

| Family | Purpose | Examples |
|---|---|---|
| `hive_*` | Git-backed task tracker: epics + subtasks | `hive_create_epic`, `hive_sync`, `hive_ready` |
| `swarmmail_*` | Coordination: **file reservations** (no conflicts), inter-agent mail | `swarmmail_reserve`, `swarmmail_send`, `swarmmail_inbox` |
| `hivemind_*` | **Semantic memory** (vector-based, via Ollama) | `hivemind_store`, `hivemind_find` |
| `swarm_*` | Decomposition, review, learning, worktrees | `swarm_decompose`, `swarm_adversarial_review`, `swarm_get_pattern_insights`, `swarm_worktree_create` |
| `structured_*` | Parsing/validation of plans (JSON/CellTree) | `swarm_validate_decomposition` |
| `cass_*` | Cross-session search across AI history | `cass_search` |

---

## 👥 Agents (25) — Who's Who

Each agent is a markdown file in `agent/` with a prompt + permissions + model.
Three groups by layer: **code** (`swarm-*`, `saas-*`, +4 auxiliary — 16 agents),
**Psyche** (`psyche-*` — 4) and **BizDev** (`biz-*` — 5).

### Idea Layer — Psyche (`/ideate`) and BizDev (`/validate`)
| Agent | Model | Role |
|---|---|---|
| `psyche-profiler` | Kimi K2 Thinking | Extracts your unfair advantages + founder-market-fit from the profile. Read-only. |
| `psyche-scout` | DeepSeek Flash +web | Searches for real market gaps matching your edge (with sources). Read-only. |
| `psyche-synthesizer` | Kimi K2 Thinking | Generates concrete ideas (advantage × gap). Read-only. |
| `psyche-critic` | MiniMax M2.7 | **Fit-adversary** — kills ideas without founder-fit. Read-only. |
| `biz-strategist` | Kimi K2 Thinking | Value prop, USP, MVP wedge, milestones. Read-only. |
| `biz-cfo` | Kimi K2 Thinking | Unit economics: pricing, COGS (including AI cost/user), CAC/LTV. Blocks when COGS ≥ price. |
| `biz-researcher` | DeepSeek Flash +web | Real competitors, prices, demand, channels — with sources. Read-only. |
| `biz-pm` | Kimi K2 Thinking | Problem-Solution Fit + coherence. Read-only. |
| `biz-demon` | MiniMax M2.7 | **Ruthless investor/competitor** — tries to KILL the business. Read-only. |

### Code Layer
Each agent is a markdown file in `agent/` with a prompt + permissions + model.
They divide into **swarm-*** (generic orchestration) and **saas-*** (specialized
for SaaS), plus 4 auxiliary agents.

### Orchestration / Planning
| Agent | Model | Role |
|---|---|---|
| `swarm-planner` | DeepSeek Pro `max` | Decomposes task into 2-7 subtasks, aware of learning loop (which strategies worked). Read-only. |
| `saas-architect` | DeepSeek Pro `max` | Analyzes SaaS repo, produces plan with file boundaries and success criteria. Read-only. |
| `archaeologist` | DeepSeek Pro `max` | Deep architecture map, data flow, change blast radius, decision history (`git blame`/`log`). Read-only. |

### Critical Workers (security / money / data)
| Agent | Model | Role |
|---|---|---|
| `saas-auth` | DeepSeek Pro `max` | Auth, sessions, permissions, OAuth, rate limiting. |
| `saas-billing` | DeepSeek Pro `max` | Stripe, subscriptions, invoices, payment webhooks. |
| `saas-db` | DeepSeek Pro `max` | Schema, migrations, indexes, seeds, RLS (row-level security). |

### General Workers
| Agent | Model | Role |
|---|---|---|
| `saas-backend` | DeepSeek Flash | API, services, server logic, integrations, webhooks. |
| `saas-frontend` | DeepSeek Flash | UI, forms, dashboards, client state. |
| `saas-test` | DeepSeek Flash | **Only** tests (`*.test.*`, `*.spec.*`) — permissions limited to test files. Flag `--integration` enables DB-backed API tests (requires local database). |
| `swarm-worker` | DeepSeek Flash | Generic subtask executor (anything beyond the above). |
| `refactorer` | DeepSeek Flash | Mechanical pattern migration across many files, preserves behavior. |
| `swarm-researcher` | DeepSeek Flash | Read-only research of documentation/API in one-shot context; saves to hivemind, returns summary. |

### Verification / Exit
| Agent | Model | Role |
|---|---|---|
| `saas-reviewer` | Kimi K2 Thinking | Read-only review: bugs, regressions, security, test coverage. Runs UBS. Different family than workers. |
| `demon` | GLM 5.2 | **Adversary** — actively tries to BREAK the change (edge cases, race conditions, OWASP). Strongest + most diverse. Read-only. |
| `saas-shipper` | DeepSeek Flash | Final verification: typecheck + lint + tests + UBS. Reports "SHIP READY" or errors. |
| `explore` | DeepSeek Flash | Fast read-only file/symbol search (`rg`). Cheap, no brain needed. |

> **Read-only** = agent has `edit: deny` — physically cannot change code. This
> is not a suggestion, it's a hard-enforced permission.

---

## 🎚️ Model Selection — and Why

**Principle: all cheap Chinese models (zero US-frontier). DeepSeek does the work;
the review gate uses DIFFERENT families so the adversary catches what DeepSeek doesn't see
in its own code.**

| Tier | Model | Who | Why |
|---|---|---|---|
| Coordinator | `deepseek/deepseek-v4-pro` (max) | `/swarm` session | Long-lived workhorse. Pro on max thinking is enough for orchestration. |
| Planners | `deepseek/deepseek-v4-pro` (max) | `plan`, `swarm-planner`, `saas-architect` | Decomposition = highest leverage; DeepSeek V4 Pro on max thinking handles it. |
| Critical workers | `deepseek/deepseek-v4-pro` (max) | auth, billing, db | Security/money/data — Pro gives more margin than Flash. |
| General workers | `deepseek/deepseek-v4-flash` | rest of saas-* + worker/refactorer/researcher/shipper | Narrow tasks → Flash is a great quality/cost ratio. |
| Reviewer | `openrouter/moonshotai/kimi-k2-thinking` | `saas-reviewer` | **Different family than workers** → catches characteristic DeepSeek errors. |
| Adversary | `openrouter/z-ai/glm-5.2` | `demon` | **Strongest + most diverse** — third family (after DeepSeek and Kimi) = max blind spot coverage. |

**Why 3 families in the gate?** Workers = DeepSeek, reviewer = Kimi, demon = GLM.
Each family has different blind spots, so the review catches errors DeepSeek doesn't
notice in its own code. This matters more than raw model power.

**Max thinking** enabled for DeepSeek Pro (default for Flash):
```jsonc
"provider": { "deepseek": { "models": {
  "deepseek-v4-pro":   { "options": { "reasoningEffort": "max" } },
  "deepseek-v4-flash": { "options": {} }
}}}
```
(`reasoningEffort` → API `reasoning_effort`; `deepseek-thinking` family supports `high`/`max`. Kimi and GLM think natively — no need to force reasoning.)

### Idea Layers (Psyche + BizDev) — three families for adversary diversification

Here adversaries run more often (you iterate on ideas), so capable but cheap models.
**Different family for the adversary** = catches different blind spots than the rest.

| Role | Model | Family | $ / Mtok (out) |
|---|---|---|---|
| Coordinators `/ideate` `/validate` | `deepseek/deepseek-v4-pro` (max) | DeepSeek | 0.87 |
| Researchers (+web) | `deepseek/deepseek-v4-flash` | DeepSeek | 0.28 |
| Analysts: profiler, synthesizer, strategist, cfo, pm | `openrouter/moonshotai/kimi-k2-thinking` | Moonshot | 2.50 |
| **Adversaries**: `psyche-critic`, `biz-demon` | `openrouter/minimax/minimax-m2.7` | MiniMax | 1.20 |

**Prices (out $/Mtok):** DeepSeek Flash 0.28 · DeepSeek Pro 0.87 · MiniMax M2.7 1.20 ·
Kimi K2 Thinking 2.50 · GLM 5.2 ~4.50. All are Chinese frontier models at a
fraction of US prices (for reference, Opus 4.8 = 25). GLM 5.2 is the most expensive in this pool,
but ~5.5× cheaper than Opus — that's why it sits in only ONE slot (code-`demon`), where
the strongest "break it" really counts.

---

## 🔄 /swarm Flow Step by Step

When you type `/swarm "task"`, the coordinator goes through phases:

| Phase | What happens | Tools |
|---|---|---|
| **0. Socratic questions** | Asks about scope/strategy, ONE question at a time with options. Skipped with `--fast`/`--auto`. | — |
| **1. Init + memory** | Joins the swarm, checks what's already known (past decisions, which strategies worked). **CASS pre-flight:** auto-searches AI history — if the problem was already solved in session X, displays a warning "Previously solved in session X" and waits for confirmation. | `swarmmail_init`, `swarm_get_strategy_insights`, `hivemind_find`, `cass_search` |
| **1.5. Research** | Only for unknown technology: spawns a researcher in one-shot context. | `Task(swarm-researcher)` |
| **2. Decomposition** | Selects strategy, splits into 2-7 subtasks with **non-overlapping** files. | `swarm_select_strategy`, `swarm_plan_prompt`, `swarm_validate_decomposition` |
| **3. Epic** | Creates epic + subtasks (tracking backed by git). | `hive_create_epic` |
| **4. Does NOT reserve files** | Coordinator does NOT reserve — workers do it themselves (otherwise deadlock). | — |
| **5. Spawn workers** | Parallel (independent) or sequential (dependencies). | `swarm_spawn_subtask` + `Task(<agent>)` |
| **6. Review gate** | After EACH worker: inbox → review → **demon** → verdict. Max 3 attempts, then escalation. | `swarm_review`, `Task(demon)`, `swarm_review_feedback` |
| **7. Ship** | After all pass: shipper runs typecheck+lint+tests+UBS. | `Task(saas-shipper)` |
| **8. Sync + learning** | Saves to git; outcomes feed the learning loop. | `hive_sync`, `swarm_complete` |

**Flags:** `--fast` (no questions), `--auto` (zero interaction), `--confirm-only`
(show plan, yes/no), `--worktrees` (each worker in its own git worktree).

**Decomposition strategies:** `file-based` (refactor/migration), `feature-based`
(new feature), `risk-based` (bugfix/security), `research-based` (exploration).

---

## ✅ Quality Gate

Three independent layers, each catches something different:

1. **`saas-reviewer`** (Kimi K2 Thinking — different family than workers) — correctness
   review: bugs, regressions, missing error handling, test coverage, patterns.
2. **`demon`** (GLM 5.2 — third family) — **adversary**: assumes the code is bad until
   it manages to break it. Edge cases, concurrency, OWASP Top 10, broken
   assumptions. Each hole must have a **concrete trigger** (repro), not "could be
   dangerous".
3. **UBS** — mechanical scanner: missing `await`, null-deref, XSS, injections,
   hardcoded secrets, resource leaks. **Every `critical` blocks.**

Reviewer and demon run **in parallel** (not sequentially) — cuts gate time from ~4 min to ~2 min. Both layers are independent, so there's no risk of mutual influence.

The gate runs **after each worker** (not collectively at the end) — errors caught immediately,
before they spread. Verdict: `approved` / `needs_changes` (retry, max 3×) /
`blocked` (escalation to you).

The worker additionally **scans its own files** with UBS before reporting completion.

---

## 🧠 Memory and Learning

Three mechanisms make the system **smarter over time**:

### 1. Hivemind — Semantic Memory (Cross-Session)
Vector database of "why", not "what": architectural decisions, root causes,
gotchas. Before work, an agent runs `hivemind_find(query=...)` — inheriting knowledge from
previous sessions. After work, `hivemind_store(...)`. Runs locally via
**Ollama + nomic-embed-text** (embeddings). Zero cloud.

### 2. Learning Loop — Pattern Promotion/Degradation
Each subtask execution records an outcome:
- **fast + success** → pattern **promoted**
- **slow + retry + errors** → pattern **flagged**
- **>60% failures** → auto-inversion to **anti-pattern** ("AVOID")
- **90-day half-life** → confidence decays if not re-confirmed

Check it: `swarm_get_pattern_insights`, `swarm_get_strategy_insights`,
`swarm_get_file_insights`. The `/retro` command summarizes this after bigger work.

### 3. CASS — Cross-Agent Search (Your Entire AI History)
Searches sessions of **all** agents (Claude Code, Codex, Cursor, OpenCode…).
Before solving a problem from scratch: `cass search "..." --robot` checks if you've
already solved it somewhere else.

### 4. Production Bug Webhook — Automatic Error Ingestion

A Bun server (`scripts/prod-webhook.ts`) listens on port `:4097` for error
reports from Sentry/LogRocket. Each reported error automatically goes into hivemind
as a learning (with context: stack trace, environment, version). Result: the system
**learns from production** — next time, the same error pattern will be
recognized before you make it.

Run: `bun run scripts/prod-webhook.ts` (or as a systemd/runit service).

---

## 🎛️ Commands

Type these in OpenCode (TUI/OpenChamber). Definitions in `command/*.md`.

### Idea Layer (Before Code)
| Command | What it does |
|---|---|
| `/profile` | **Layer 0** — pulls your **full profile** (`profile/jakub/`) and distills it into `profile/founder-fit.md` (unfair advantages, energy map, anti-fit, channels). Run **once**, refresh when life changes. |
| `/ideate "<domain or silence>"` | **Psyche** — reads the bundle + founder-fit, generates ideas for **your** unfair advantage; fit-critic kills those without founder-fit. → `0-opportunity.md` in `~/Desktop/1-Projects/_ideas/<slug>/`. |
| `/validate "<idea>"` | **BizDev** — web research, unit economics (including AI cost/user), product-fit + ruthless demon-investor. → `GO/KILL/PIVOT`, on GO `2-plan.md`. Flag `--brutal` = harsher demon. |

### Coding
| Command | What it does |
|---|---|
| `/swarm "description"` | Full flow (see above). **For: feature, 3+ file refactor, bug+tests.** |

### Supporting
| Command | When |
|---|---|
| `/swarm-status` | Progress of a running swarm: epic, subtasks, blockers, what's ready to spawn. |
| `/review` | Ad-hoc adversarial review of dirty diff (reviewer + demon + UBS), no changes. |
| `/iterate "..."` | Improve→evaluate loop until it passes the demon and tests (max 3 rounds). |
| `/parallel "a" "b"` | Known, independent tasks in parallel (when you already know the split). |
| `/worktree-task "..."` | Risky/parallel work in an isolated git worktree. |
| `/retro` | After a swarm: what the system learned, anti-patterns, sync. |
| `/costs` | Cost panel for the last swarm session: tokens in/out per model, USD cost, comparison with budget. Includes a table with current model prices. |
| `/commit` | Gate (typecheck+lint+tests+UBS, no secrets) → clean Conventional Commit. |
| `/pr-create` | Push + PR with structured description (via `gh`; without `gh` gives compare-URL). |

---

## 🛠️ Tools (Engine)

| Tool | Version | Role | Critical? |
|---|---|---|---|
| **swarm** | 0.63.2 | Orchestration engine — all `hive_*`/`swarmmail_*`/`hivemind_*`/`swarm_*` tools. | ✅ core |
| **OpenCode** | 1.17.7 | Agent host (TUI). OpenChamber is the GUI over it. | ✅ core |
| **Ollama** | 0.30.9 | Local embeddings (`nomic-embed-text`) for semantic memory. Launchd service in the background. | ✅ for hivemind |
| **UBS** | 5.3.2 | AI bug scanner. Quality gate. | ✅ quality |
| **CASS** | 0.6.16 | Cross-agent session search. | ⚪ optional (helpful) |
| **gh** | 2.94.0 | GitHub CLI — automatic PRs. | ⚪ for `/pr-create` |
| **bash** | 5.3 | UBS requires bash ≥4 (macOS has 3.2). | ✅ for UBS |
| **bun / node** | 1.3.14 / — | Runtime for plugin and tooling. | ✅ core |

UBS and CASS come from the author's official Homebrew taps (Dicklesworthstone), MIT,
SHA-verified.

---

## 🧩 Skills (Knowledge on Demand)

The agent **loads a skill itself** when the task matches its description — doesn't
clutter context preemptively (unlike `AGENTS.md`, which is always present).
Native OpenCode mechanism: `~/.config/opencode/skills/<name>/SKILL.md`.

| Skill | When it fires |
|---|---|
| `testing-patterns` | Tests for legacy/untested code (characterization, breaking dependencies per Feathers, what to test in SaaS, unit vs integration vs e2e). |
| `root-cause-debugging` | Something crashes / is flaky — systematic: reproduction → isolation → hypothesis → fix the **cause**, not the symptom. |
| `saas-security-review` | Changes in auth / billing / multitenancy — OWASP playbook in attack→check→fix format (IDOR, mass-assignment, forged webhooks, idempotency…). |
| `customize-opencode` | (built into OpenCode) Editing the OpenCode config itself. |

---

## 📚 Knowledge Files (`knowledge/`)

Loaded by reference `@knowledge/<file>.md` (when the agent needs them):

| File | Contents |
|---|---|
| `saas-patterns.md` | Universal SaaS patterns: multitenancy, idempotency, webhooks, billing, auth/sessions, queues/jobs, migrations, API, observability. |
| `security-checklist.md` | OWASP checklist: injection, authn/authz, secrets, SSRF, rate limiting, concurrency, logging. |

Difference from skills: knowledge = **reference** pulled in deliberately; skills =
**auto-detected** by description. Both loaded on demand (not preemptively).

---

## 📁 File Structure

```
~/.config/opencode/
├── opencode.jsonc        ← models, providers (DeepSeek max + Kimi/MiniMax), MCP, permissions
├── AGENTS.md             ← rules for ALL agents (always in context)
├── agent/  (25)          ← code layer (16) + psyche-* (4) + biz-* (5)
│   ├── swarm-planner.md       saas-architect.md     archaeologist.md
│   ├── saas-auth.md           saas-billing.md       saas-db.md
│   ├── saas-backend.md        saas-frontend.md      saas-test.md
│   ├── swarm-worker.md        refactorer.md         swarm-researcher.md
│   ├── saas-reviewer.md       demon.md              saas-shipper.md  explore.md
│   ├── psyche-profiler.md     psyche-scout.md       psyche-synthesizer.md  psyche-critic.md
│   └── biz-strategist.md      biz-cfo.md            biz-researcher.md  biz-pm.md  biz-demon.md
├── command/  (12)        ← /profile /ideate /validate /swarm /review /commit /pr-create /retro ...
├── skills/  (3)          ← testing-patterns, root-cause-debugging, saas-security-review
├── knowledge/  (3)       ← saas-patterns.md, security-checklist.md, venture-pipeline.md
└── plugin/swarm.ts       ← plugin wrapper (absolute paths — GUI-safe)

~/Desktop/                  ← Your desktop organized in PARA (0-Inbox, 1-Projects, 2-Areas, 3-Resources)
├── 3-Resources/profile/
│   ├── jakub/             ← LAYER 0 — your full bundle (source of truth, read directly)
│   └── founder-fit.md     ← business lens (distilled by /profile)
└── 1-Projects/
    ├── _ideas/<slug>/     ← incubator: 0-opportunity → 1-validation → 2-plan.md
    └── <slug>/            ← after GO, the idea PROMOTES here as a real project (code)

~/.local/share/opencode/auth.json   ← deepseek + openrouter keys (⛔ DO NOT TOUCH)
~/.config/opencode.backup-*         ← backup of previous config
```

**Why absolute paths in the plugin?** OpenChamber (GUI) starts without a shell
PATH. The plugin calls CLIs by full path (`~/.config/opencode/node_modules/.bin/swarm`,
`~/.nix-profile/bin/opencode`) and prepends `/home/me/.nix-profile/bin` to PATH on spawn —
so that `cass`/`ubs`/`ollama`/`bash5` are found in the GUI.

---

## 🔑 Git / GitHub (Configured)

| Element | Status |
|---|---|
| Protocol | **SSH** (key `~/.ssh/id_ed25519`, in ssh-agent + Keychain macOS) |
| Key on GitHub | `mac-m2-2026-06` (type: authentication) |
| `gh` CLI | logged in as **`mggpie`** (scope: repo, admin:public_key, …) |
| Commit identity | `mggpie <57095596+mggpie@users.noreply.github.com>` (no-reply — no private email) |
| Default branch | `main` |
| Fallback | `gh auth setup-git` set → HTTPS also works if SSH fails |
| Test | `ssh -T git@github.com` → *"Hi mggpie! You've successfully authenticated"* ✅ |

`git clone`/`push`/`pull` over SSH works — including **private repos**. `/pr-create`
opens PRs via `gh`. Old key `void` (from Linux) is on the GitHub account, but
physically not on this Mac — irrelevant.

---

## 🍳 Recipes — Common Scenarios

**Full pipeline (from scratch, idea to code):**
```fish
cd ~/Desktop/1-Projects/_ideas
/profile                               # ONCE: pulls your full profile → 3-Resources/profile/founder-fit.md
/ideate "tools for solo AI devs"        # → _ideas/<slug>/0-opportunity.md, pick 1 idea
# review the brief, then from 1-Projects/_ideas/<slug>/:
/validate "<chosen idea>"               # → GO/KILL/PIVOT; on GO promotes to 1-Projects/<slug>/ + 2-plan.md
# if GO — in that project / code repo:
/swarm "<from 2-plan.md>"               # builds the wedge
/commit  →  /pr-create
```
Most ideas **will die** at `/ideate` or `/validate` — that's the goal. Cheap death
in console > 3 months of coding something nobody will pay for.

**Validate an existing idea only:**
```
/validate "SaaS for X for Y" --brutal   # harsher demon + additional CFO round
```

**New feature:**
```
/swarm "add PDF invoice export with template"
→ answer 1-2 questions (or add --fast)
→ watch: architect plans → workers write → demon hunts holes → shipper
/commit  →  /pr-create
```

**Bugfix (with regression test):**
```
/swarm "fix: Stripe webhook double-charges on retry (+ test)"
```
(risk-based strategy → failing test first, then root cause fix)

**Quick pre-commit review:**
```
/review        ← reviewer + demon + UBS on dirty diff, no changes
```

**Multi-file refactor:**
```
/swarm "migrate all old API client calls to the new one --worktrees"
```

**After bigger work — persist learning:**
```
/retro         ← what worked, what anti-patterns, sync
```

**Check if you've already solved this:**
```fish
cass search "stripe webhook idempotency" --robot --limit 5
```

---

## 🔧 Diagnostics

| Problem | Check |
|---|---|
| Config won't load | `opencode debug config` (parsed JSON or error) |
| Agent doesn't see a skill | `opencode debug skill` (list of detected skills) |
| Agent models | `opencode debug config | jq '.agent'` |
| Swarm dependencies | `swarm doctor` |
| Available models | `opencode models | grep deepseek` |
| Ollama alive? | `curl -s localhost:11434/api/version` |
| SSH to GitHub | `ssh -T git@github.com` |

> **UBS in `swarm doctor` shows "not found"** — this is a **false alarm**. `swarm
> doctor` calls `ubs` via `/usr/bin/env bash`, which in your PATH hits
> macOS bash 3.2 (UBS requires ≥4). Agents call UBS correctly via
> `/bin/bash /home/me/.nix-profile/bin/ubs` and **it works** (verified —
> catches bugs). Purely cosmetic.

---

## ⛔ What NOT to Do

- **Don't run `swarm setup`** — it regenerates `plugin/swarm.ts` (removes the
  `liteModel` fix for DeepSeek + PATH injection for GUI) and overwrites `AGENTS.md`.
  Defaults to opus/sonnet/**haiku** (haiku/anthropic not in your auth).
  Everything already works without it.
- **Don't touch `auth.json`** — that's where API keys live (deepseek + openrouter).
- **Don't commit with `--no-verify`** — bypasses the quality gate. `/commit` enforces this.
- **Remember to restart** — after changing something in `~/.config/opencode/`, restart
  OpenCode/OpenChamber (config loads once at startup, no hot-reload).

---

## 📖 Glossary

| Term | Meaning |
|---|---|
| **Coordinator** | Main agent of the `/swarm` session. Brain — orchestrates, doesn't write code. |
| **Worker** | Agent executing one subtask in one-shot context. |
| **Subtask / bead** | Atomic unit of work with file boundaries, tracked in hive. |
| **Epic** | Collection of subtasks = the entire `/swarm` task, backed by git. |
| **Reservation (swarmmail)** | Worker "locks" files it edits → no conflicts with other workers. |
| **Demon** | Adversary (GLM 5.2) — tries to break the code before it ships. |
| **Hivemind** | Semantic (vector) memory across sessions. |
| **Learning loop** | Pattern promotion/degradation system based on outcomes. |
| **Anti-pattern** | Strategy auto-marked as bad (>60% failure) → "AVOID". |
| **Worktree** | Isolated git working copy (separate branch) per worker. |
| **UBS** | Ultimate Bug Scanner — mechanical AI bug scanner. |
| **CASS** | Cross-Agent Session Search — search across your entire AI history. |
| **max thinking** | `reasoningEffort: max` — DeepSeek thinks maximally from the start. |
| **read-only agent** | Agent with `edit: deny` — physically cannot change code. |
| **unfair advantage** | Edge that competitors can't copy (rare skill combo, survival, asset, way of thinking). Core of the Psyche layer. |
| **founder-market fit** | Whether this specific founder can handle and win in this market — and whether it won't burn them out. |
| **founder churn** | Business death because the founder burned out/got bored (not because of the market). `anti-fit.md` protects against this. |
| **COGS / unit economics** | Cost to serve 1 user (in AI: tokens/user!). If COGS ≥ price → business bleeds. |
| **wedge** | The smallest thing you build first that's already worth paying for. |
| **artifact handoff** | `0-opportunity.md` → `1-validation.md` → `2-plan.md` — contract between layers. |

---

*Generated: 2026-06-20 • OpenCode 1.17.7 + swarm 0.63.2 + OpenChamber*
*Pipeline: `/ideate` (Psyche) → `/validate` (BizDev) → `/swarm` (Code) — same engine, 3 layers*
