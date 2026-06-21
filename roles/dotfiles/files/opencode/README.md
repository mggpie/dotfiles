# 🐝 OpenCode Swarm — pełny przewodnik

Multi-agentowy system do **wymyślania, walidacji i budowy** produktów/SaaS-ów w
**OpenCode 1.17.7 + OpenChamber** (GUI) na MacBooku Air M2.

> **Jedno zdanie:** drogi model **myśli i ocenia**, tanie modele **wykonują**,
> a twarda **bramka jakości + pamięć** sprawiają, że tanie modele dają dobry wynik.

> **Trzy warstwy:** `/ideate` (jaki pomysł pasuje do mnie?) → `/validate` (czy ktoś
> za to zapłaci?) → `/swarm` (zbuduj to). Ten sam silnik, inne klocki. Bramka
> ludzka między warstwami. Przed nimi **Warstwa 0** (`/profile`) wciąga Twój
> **pełny profil** i destyluje go w soczewkę founder-fit.

---

## 📖 Spis treści

1. [Dlaczego to powstało](#-dlaczego-to-powstało)
2. [Pipeline: od pomysłu do kodu (3 warstwy)](#-pipeline-od-pomysłu-do-kodu-3-warstwy)
3. [Jak to działa — model myślowy](#-jak-to-działa--model-myślowy)
4. [Architektura — z czego się składa](#-architektura--z-czego-się-składa)
5. [Agenci (25) — kto jest kim](#-agenci-25--kto-jest-kim)
6. [Dobór modeli — i dlaczego tak](#-dobór-modeli--i-dlaczego-tak)
7. [Przepływ `/swarm` krok po kroku](#-przepływ-swarm-krok-po-kroku)
8. [Bramka jakości](#-bramka-jakości)
9. [Pamięć i uczenie się](#-pamięć-i-uczenie-się)
10. [Komendy](#-komendy)
11. [Narzędzia (silnik)](#-narzędzia-silnik)
12. [Skille](#-skille-wiedza-na-żądanie)
13. [Pliki wiedzy](#-pliki-wiedzy-knowledge)
14. [Struktura plików](#-struktura-plików)
15. [Git / GitHub](#-git--github-skonfigurowane)
16. [Przepisy — typowe sytuacje](#-przepisy--typowe-sytuacje)
17. [Diagnostyka](#-diagnostyka)
18. [Czego NIE robić](#-czego-nie-robić)
19. [Słownik pojęć](#-słownik-pojęć)

---

## 🎯 Dlaczego to powstało

**Problem.** Pojedynczy model AI piszący cały SaaS ma trzy wady:
- **Drogi**, jeśli mocny — albo **słaby**, jeśli tani.
- Traci kontekst przy dużych zadaniach (jeden wątek = jedno okno kontekstu).
- Nikt nie sprawdza jego pracy poza Tobą.

**Teza tego setupu.** Rozdziel **myślenie** od **wykonania**:
- Zero drogich modeli US (żadnego Opus/GPT). Same tanie chińskie modele — a bramkę
  review zróżnicuj: workerzy DeepSeek, reviewer Kimi, adwersarz GLM (inne rodziny =
  inne ślepe plamy).
- Tanie modele (DeepSeek V4) robią właściwą robotę — ale **na max thinkingu** i
  na **wąskim tasku**. Worker nie musi rozumieć całego repo, tylko swój kawałek.
- **Bramka jakości** (review + adwersarz + skaner błędów) wyłapuje to, czego tani
  model nie dopilnuje.
- **Pamięć między sesjami** sprawia, że system **uczy się** — kolejne zadania są
  lepsze, bo zna wcześniejsze decyzje i błędy.

**Efekt.** Koszt drogiego modelu tylko tam, gdzie się opłaca; jakość mimo tanich
wykonawców; izolacja workerów (brak konfliktów); i system, który z czasem mądrzeje.

---

## 🧭 Pipeline: od pomysłu do kodu (3 warstwy)

Code-swarm świetnie buduje **zdefiniowany** problem („napisz webhooki Stripe"), ale
nie wymyśli za Ciebie biznesu ani nie powie, że **nikt za to nie zapłaci**. Więc ten
sam silnik (orkiestracja, hive, swarmmail, hivemind, learning loop, adwersarz)
został przepięty **w górę** — do pomysłów i walidacji. Trzy warstwy, sekwencyjnie,
z **bramką ludzką** między każdą:

```  WARSTWA 0 (Profil)
  /profile  →  profile/founder-fit.md      (wciąga CAŁY Twój bundle z PARA)
       │
       ▼  zasila ↓  WARSTWA 3 (Psyche)        WARSTWA 2 (BizDev)         WARSTWA 1 (Code)
  /ideate              →    /validate             →    /swarm   (istniało)
  „który pomysł pasuje       „czy ktoś za to             „zbuduj zaakceptowany
   do mnie i mojego           zapłaci? zabij              wedge"
   unfair advantage?"        albo wyostrz"
       │                          │                           │
       ▼                          ▼                           ▼
  0-opportunity.md   →      1-validation.md      →      2-plan.md  →  kod + PR
       │                          │                           │
       └── Ty akceptujesz ────────┴── Ty akceptujesz ─────────┘
```

**Dlaczego osobne warstwy, nie jeden mega-swarm:** czyste role (koordynator się nie
rozdmuchuje), inne modele per warstwa (koszt), i — kluczowe — **Ty akceptujesz
przejście**. Pomysł musi przejść Twój accept, zanim pójdzie dalej. Artefakt (`.md`) +
hivemind = handoff. Każda warstwa zasila pamięć → kolejne przedsięwzięcia dziedziczą
co zadziałało (i co zabiło poprzednie pomysły).

### Trzy tryby śmierci, trzej adwersarze

Pomysł musi przeżyć **trzech różnych adwersarzy**, żeby stać się płatnym produktem:

| Warstwa | Adwersarz | Zabija pomysł, gdy… |
|---|---|---|
| Psyche | `psyche-critic` | **brak founder-fit** — każdy mógłby to zbudować, walczy z Twoją naturą, brak moatu z **Twojego** edge'a |
| BizDev | `biz-demon` | **brak biznesu** — brak rynku, CAC > LTV, COGS zjada marżę, incumbent miażdży, churn, founder burnout |
| Code | `demon` | **zła implementacja** — edge case'y, race conditions, OWASP |

### Mina: AI to potakiwacz
Świadomie wbudowane kontry (w promptach adwersarzy): domyślna postawa „to **upadnie**"
(pass wymaga realnej, nieudanej próby zabicia); każdy atak musi cytować **realne dane**
(researcherzy mają web), nie wiedzę ogólną sprzed roku; **twardy gate**: jeśli
COGS ≥ cena → `needs_changes`. Oczekiwany wysoki kill-rate — jeśli adwersarz łatwo
przepuszcza, jest miękki → `/validate --brutal`.

### Warstwa 0: Twój profil (przed Psyche)
Twój **pełny profil** żyje w Twoim systemie **PARA** — pipeline czyta go **wprost**
(bez kopii, bez symlinka):
`~/Desktop/3-Resources/profile/jakub/` — bogaty RAG-bundle
(`knowledge-base.md` → `timeline.md` → `canonical.md`). To źródło prawdy.

Komenda **`/profile`** (warstwa 0) wciąga **CAŁY** ten bundle i destyluje go w
`~/Desktop/3-Resources/profile/founder-fit.md` — soczewkę biznesową: unfair
advantages, energy map, anti-fit, kanały dystrybucji, produktyzowalne assety.
Dopytuje tylko o realne luki biznesowe (kanały, co Cię wypala w *prowadzeniu*
biznesu) — resztę bierze z profilu. `/ideate` czyta potem **i bundle, i founder-fit.md**.

Bundle jest psychologiczny; `founder-fit.md` to jego **biznesowe tłumaczenie**.
Pipeline nigdy nie kopiuje wrażliwych szczegółów do artefaktów — tłumaczy je na
sygnał biznesowy (wartości typu autonomia finansowa / spokój / niski people-overhead
→ jakie modele biznesowe **wykluczają**). Founder churn zabija więcej startupów niż
złe rynki — dlatego anti-fit jest kluczowy. To founder-market-fit, nie terapia.

Odpalasz raz: `/profile`. Odświeżasz, gdy zmieni się sytuacja życiowa.

---

## 🧠 Jak to działa — model myślowy

**Mózg vs ręce.** Koordynator to mózg: orkiestruje, **nigdy nie pisze kodu**.
Workerzy to ręce: dostają wąski task w jednorazowym kontekście, robią, znikają.

```
            ┌──────────────────────────────────────────────┐
   TY ─────▶│  KOORDYNATOR (mózg, DeepSeek V4 Pro · max)    │
  /swarm    │  • pyta o zakres   • dekomponuje na subtaski  │
            │  • spawnuje        • monitoruje   • decyduje  │
            │  • NIGDY nie edytuje kodu                     │
            └───────────────┬──────────────────────────────┘
                            │ spawnuje równolegle/sekwencyjnie
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
  ┌───────────┐       ┌───────────┐       ┌───────────┐
  │ WORKER A  │       │ WORKER B  │       │ WORKER C  │   ← jednorazowy kontekst
  │ rezerwuje │       │ rezerwuje │       │ rezerwuje │   ← swarmmail_reserve
  │ pliki,    │       │ pliki,    │       │ pliki,    │   ← brak konfliktów
  │ pisze,    │       │ pisze,    │       │ pisze,    │
  │ testuje   │       │ testuje   │       │ testuje   │
  └─────┬─────┘       └─────┬─────┘       └─────┬─────┘
        └───────────────────┼───────────────────┘
                            ▼
            ┌──────────────────────────────────────────────┐
            │  BRAMKA JAKOŚCI (po KAŻDYM workerze)          │
            │  reviewer (Kimi) + demon (GLM) + UBS scan     │
            │  approved? → dalej   needs_changes? → retry   │
            └───────────────┬──────────────────────────────┘
                            ▼
            ┌──────────────────────────────────────────────┐
            │  SHIPPER → typecheck + lint + testy + UBS     │
            │  → hive_sync (zapis do gita)                  │
            │  → learning loop (zapamiętaj co zadziałało)   │
            └──────────────────────────────────────────────┘
```

**Dlaczego workerzy mają jednorazowy kontekst?** Bo równoległa praca nie może
zapchać jednego okna kontekstu. Każdy worker dostaje czysty, wąski kontekst →
tańszy, szybszy, mniej się myli. Koordynator zachowuje czysty, długowieczny
kontekst tylko na orkiestrację.

---

## 🏗️ Architektura — z czego się składa

Pięć warstw. Wszystko żyje w `~/.config/opencode/`.

| Warstwa | Co to | Pliki / mechanizm |
|---|---|---|
| **1. Orkiestracja** | Koordynator + przepływ `/swarm` | `command/swarm.md`, `AGENTS.md` |
| **2. Agenci** | 16 wyspecjalizowanych ról | `agent/*.md` |
| **3. Silnik (toole)** | Plugin swarma daje toole, których agenci używają | `plugin/swarm.ts` → CLI `swarm` |
| **4. Bramka jakości** | Review + adwersarz + skaner błędów | reviewer/demon + UBS |
| **5. Pamięć** | Uczenie się między sesjami | hivemind (Ollama), learning loop, CASS |

**Kluczowy insight:** wszystkie „super-funkcje" (epiki, rezerwacje plików, pamięć
semantyczna, adversarial review, learning loop, worktrees) to **natywne toole
pluginu swarm 0.63.2** — nie trzeba było ich pisać. Robota polegała na agentach,
komendach i regułach (`AGENTS.md`), które te toole **wykorzystują**.

**Rodziny tooli** (plugin udostępnia je agentom):

| Rodzina | Do czego | Przykłady |
|---|---|---|
| `hive_*` | Tracker pracy backed gitem: epiki + subtaski | `hive_create_epic`, `hive_sync`, `hive_ready` |
| `swarmmail_*` | Koordynacja: **rezerwacje plików** (brak konfliktów), poczta między agentami | `swarmmail_reserve`, `swarmmail_send`, `swarmmail_inbox` |
| `hivemind_*` | **Pamięć semantyczna** (wektorowa, przez Ollamę) | `hivemind_store`, `hivemind_find` |
| `swarm_*` | Dekompozycja, review, learning, worktrees | `swarm_decompose`, `swarm_adversarial_review`, `swarm_get_pattern_insights`, `swarm_worktree_create` |
| `structured_*` | Parsowanie/walidacja planów (JSON/CellTree) | `swarm_validate_decomposition` |
| `cass_*` | Cross-session search po historii AI | `cass_search` |

---

## 👥 Agenci (25) — kto jest kim

Każdy agent to plik markdown w `agent/` z promptem + uprawnieniami + modelem.
Trzy grupy wg warstwy: **kod** (`swarm-*`, `saas-*`, +4 pomocnicze — 16 agentów),
**Psyche** (`psyche-*` — 4) i **BizDev** (`biz-*` — 5).

### Warstwa pomysłów — Psyche (`/ideate`) i BizDev (`/validate`)
| Agent | Model | Rola |
|---|---|---|
| `psyche-profiler` | Kimi K2 Thinking | Wyciąga Twoje unfair advantages + founder-market-fit z profilu. Read-only. |
| `psyche-scout` | DeepSeek Flash +web | Szuka realnych luk rynkowych pod Twój edge (z źródłami). Read-only. |
| `psyche-synthesizer` | Kimi K2 Thinking | Generuje konkretne pomysły (advantage × luka). Read-only. |
| `psyche-critic` | MiniMax M2.7 | **Fit-adwersarz** — zabija pomysły bez founder-fit. Read-only. |
| `biz-strategist` | Kimi K2 Thinking | Value prop, USP, MVP wedge, milestones. Read-only. |
| `biz-cfo` | Kimi K2 Thinking | Unit economics: pricing, COGS (z kosztem AI/user), CAC/LTV. Blokuje, gdy COGS ≥ cena. |
| `biz-researcher` | DeepSeek Flash +web | Realni konkurenci, ceny, popyt, kanały — z źródłami. Read-only. |
| `biz-pm` | Kimi K2 Thinking | Problem-Solution Fit + spójność. Read-only. |
| `biz-demon` | MiniMax M2.7 | **Bezwzględny inwestor/konkurent** — próbuje ZABIĆ biznes. Read-only. |

### Warstwa kodu
Każdy agent to plik markdown w `agent/` z promptem + uprawnieniami + modelem.
Dzielą się na **swarm-*** (generyczna orkiestracja) i **saas-*** (wyspecjalizowane
pod SaaS), plus 4 pomocnicze.

### Orkiestracja / planowanie
| Agent | Model | Rola |
|---|---|---|
| `swarm-planner` | DeepSeek Pro `max` | Dekomponuje task na 2-7 subtasków, świadomy learning loopu (które strategie działały). Read-only. |
| `saas-architect` | DeepSeek Pro `max` | Analizuje repo SaaS, produkuje plan z granicami plików i kryteriami sukcesu. Read-only. |
| `archaeologist` | DeepSeek Pro `max` | Głęboka mapa architektury, przepływ danych, „blast radius" zmiany, historia decyzji (`git blame`/`log`). Read-only. |

### Workerzy krytyczni (bezpieczeństwo / kasa / dane)
| Agent | Model | Rola |
|---|---|---|
| `saas-auth` | DeepSeek Pro `max` | Auth, sesje, uprawnienia, OAuth, rate limiting. |
| `saas-billing` | DeepSeek Pro `max` | Stripe, subskrypcje, faktury, webhooki płatności. |
| `saas-db` | DeepSeek Pro `max` | Schema, migracje, indeksy, seedy, RLS (row-level security). |

### Workerzy ogólni
| Agent | Model | Rola |
|---|---|---|
| `saas-backend` | DeepSeek Flash `max` | API, serwisy, logika serwerowa, integracje, webhooki. |
| `saas-frontend` | DeepSeek Flash `max` | UI, formularze, dashboardy, stan kliencki. |
| `saas-test` | DeepSeek Flash `max` | **Tylko** testy (`*.test.*`, `*.spec.*`) — uprawnienia ograniczone do plików testowych. |
| `swarm-worker` | DeepSeek Flash `max` | Generyczny wykonawca subtaska (cokolwiek poza powyższymi). |
| `refactorer` | DeepSeek Flash `max` | Mechaniczna migracja wzorca po wielu plikach, zachowuje zachowanie. |
| `swarm-researcher` | DeepSeek Flash `max` | Read-only research dokumentacji/API w jednorazowym kontekście; zapisuje do hivemind, zwraca skrót. |

### Weryfikacja / wyjście
| Agent | Model | Rola |
|---|---|---|
| `saas-reviewer` | Kimi K2 Thinking | Read-only review: bugi, regresje, bezpieczeństwo, pokrycie testami. Odpala UBS. Inna rodzina niż workerzy. |
| `demon` | GLM 5.2 | **Adwersarz** — aktywnie próbuje ZŁAMAĆ zmianę (edge case'y, race conditions, OWASP). Najmocniejszy + najbardziej zróżnicowany. Read-only. |
| `saas-shipper` | DeepSeek Flash `max` | Finalna weryfikacja: typecheck + lint + testy + UBS. Raportuje „SHIP READY" lub błędy. |
| `explore` | DeepSeek Flash `max` | Szybkie read-only wyszukiwanie plików/symboli (`rg`). Tani, brain niepotrzebny. |

> **Read-only** = agent ma `edit: deny` — fizycznie nie może zmienić kodu. To
> nie sugestia, to twardo egzekwowane uprawnienie.

---

## 🎚️ Dobór modeli — i dlaczego tak

**Zasada: same tanie chińskie modele (zero US-frontier). DeepSeek robi robotę;
bramka review używa INNYCH rodzin, żeby adwersarz łapał to, czego DeepSeek nie widzi
we własnym kodzie.**

| Tier | Model | Kto | Dlaczego |
|---|---|---|---|
| Koordynator | `deepseek/deepseek-v4-pro` (max) | sesja `/swarm` | Długowieczny workhorse. Pro na max thinkingu wystarcza do orkiestracji. |
| Planiści | `deepseek/deepseek-v4-pro` (max) | `plan`, `swarm-planner`, `saas-architect` | Dekompozycja = najwyższa dźwignia; DeepSeek V4 Pro na max thinkingu daje radę. |
| Workerzy krytyczni | `deepseek/deepseek-v4-pro` (max) | auth, billing, db | Bezpieczeństwo/kasa/dane — Pro daje większy margines niż Flash. |
| Workerzy ogólni | `deepseek/deepseek-v4-flash` (max) | reszta saas-* + worker/refactorer/researcher/shipper | Wąskie taski → Flash na max thinkingu = świetny stosunek jakość/koszt. |
| Reviewer | `openrouter/moonshotai/kimi-k2-thinking` | `saas-reviewer` | **Inna rodzina niż workerzy** → łapie charakterystyczne błędy DeepSeeka. |
| Adwersarz | `openrouter/z-ai/glm-5.2` | `demon` | **Najmocniejszy + najbardziej zróżnicowany** — trzecia rodzina (po DeepSeek i Kimi) = max pokrycie ślepych plam. |

**Dlaczego 3 rodziny w bramce?** Workerzy = DeepSeek, reviewer = Kimi, demon = GLM.
Każda rodzina ma inne ślepe plamy, więc review łapie błędy, których DeepSeek nie
zauważa w swoim własnym kodzie. To ważniejsze niż surowa moc jednego modelu.

**Max thinking** włączony globalnie dla obu DeepSeeków:
```jsonc
"provider": { "deepseek": { "models": {
  "deepseek-v4-pro":   { "options": { "reasoningEffort": "max" } },
  "deepseek-v4-flash": { "options": { "reasoningEffort": "max" } }
}}}
```
(`reasoningEffort` → API `reasoning_effort`; rodzina `deepseek-thinking` wspiera `high`/`max`. Kimi i GLM myślą z natury — nie wymuszasz reasoningu.)

### Warstwy pomysłów (Psyche + BizDev) — trzy rodziny dla dywersyfikacji adwersarza

Tu adwersarze chodzą częściej (iterujesz pomysły), więc mocne, ale tanie modele.
**Inna rodzina dla adwersarza** = łapie inne ślepe plamy niż reszta.

| Rola | Model | Rodzina | $ / Mtok (out) |
|---|---|---|---|
| Koordynatorzy `/ideate` `/validate` | `deepseek/deepseek-v4-pro` (max) | DeepSeek | 0.87 |
| Researcherzy (+web) | `deepseek/deepseek-v4-flash` (max) | DeepSeek | 0.28 |
| Analitycy: profiler, synthesizer, strategist, cfo, pm | `openrouter/moonshotai/kimi-k2-thinking` | Moonshot | 2.50 |
| **Adwersarze**: `psyche-critic`, `biz-demon` | `openrouter/minimax/minimax-m2.7` | MiniMax | 1.20 |

**Ceny (out $/Mtok):** DeepSeek Flash 0.28 · DeepSeek Pro 0.87 · MiniMax M2.7 1.20 ·
Kimi K2 Thinking 2.50 · GLM 5.2 ~4.50. Wszystkie to chińskie modele frontier za
ułamek ceny US (dla odniesienia Opus 4.8 = 25). GLM 5.2 jest najdroższy z tej puli,
ale ~5.5× tańszy od Opusa — dlatego siedzi tylko w JEDNYM slocie (kod-`demon`), gdzie
najmocniejszy „złam to" naprawdę się liczy.

---

## 🔄 Przepływ `/swarm` krok po kroku

Gdy wpisujesz `/swarm "zadanie"`, koordynator przechodzi przez fazy:

| Faza | Co się dzieje | Toole |
|---|---|---|
| **0. Sokratejskie pytania** | Dopytuje o zakres/strategię, JEDNO pytanie naraz z opcjami. Pomijane przez `--fast`/`--auto`. | — |
| **1. Init + pamięć** | Dołącza do swarma, sprawdza co już wiadomo (poprzednie decyzje, które strategie działały). | `swarmmail_init`, `swarm_get_strategy_insights`, `hivemind_find` |
| **1.5. Research** | Tylko dla nieznanej technologii: spawnuje researchera w jednorazowym kontekście. | `Task(swarm-researcher)` |
| **2. Dekompozycja** | Wybiera strategię, dzieli na 2-7 subtasków z **nienakładającymi się** plikami. | `swarm_select_strategy`, `swarm_plan_prompt`, `swarm_validate_decomposition` |
| **3. Epic** | Tworzy epic + subtaski (śledzenie backed gitem). | `hive_create_epic` |
| **4. NIE rezerwuje plików** | Koordynator NIE rezerwuje — workerzy robią to sami (inaczej deadlock). | — |
| **5. Spawn workerów** | Równolegle (niezależne) lub sekwencyjnie (zależności). | `swarm_spawn_subtask` + `Task(<agent>)` |
| **6. Bramka review** | Po KAŻDYM workerze: inbox → review → **demon** → werdykt. Max 3 próby, potem eskalacja. | `swarm_review`, `Task(demon)`, `swarm_review_feedback` |
| **7. Ship** | Po przejściu wszystkich: shipper odpala typecheck+lint+testy+UBS. | `Task(saas-shipper)` |
| **8. Sync + nauka** | Zapis do gita; outcome'y zasilają learning loop. | `hive_sync`, `swarm_complete` |

**Flagi:** `--fast` (bez pytań), `--auto` (zero interakcji), `--confirm-only`
(pokaż plan, tak/nie), `--worktrees` (każdy worker w osobnym git worktree).

**Strategie dekompozycji:** `file-based` (refactor/migracja), `feature-based`
(nowy feature), `risk-based` (bugfix/security), `research-based` (eksploracja).

---

## ✅ Bramka jakości

Trzy niezależne pasy, każdy łapie co innego:

1. **`saas-reviewer`** (Kimi K2 Thinking — inna rodzina niż workerzy) — przegląd
   poprawnościowy: bugi, regresje, brakujące error handling, pokrycie testami, wzorce.
2. **`demon`** (GLM 5.2 — trzecia rodzina) — **adwersarz**: zakłada, że kod jest zły, dopóki nie
   uda mu się go złamać. Edge case'y, concurrency, OWASP Top 10, złamane
   założenia. Każda dziura musi mieć **konkretny trigger** (repro), nie „może być
   niebezpieczne".
3. **UBS** — mechaniczny skaner: brak `await`, null-deref, XSS, wstrzyknięcia,
   hardcoded secrets, wycieki zasobów. **Każdy `critical` blokuje.**

Bramka działa **po każdym workerze** (nie zbiorczo na końcu) — błąd łapany od razu,
zanim się rozleje. Werdykt: `approved` / `needs_changes` (retry, max 3×) /
`blocked` (eskalacja do Ciebie).

Worker dodatkowo **sam skanuje** swoje pliki UBS-em przed zgłoszeniem ukończenia.

---

## 🧠 Pamięć i uczenie się

Trzy mechanizmy sprawiają, że system **mądrzeje z czasem**:

### 1. Hivemind — pamięć semantyczna (między sesjami)
Wektorowa baza „dlaczego", nie „co": decyzje architektoniczne, root cause'y,
gotcha. Agent przed robotą robi `hivemind_find(query=...)` — dziedziczy wiedzę z
poprzednich sesji. Po robocie `hivemind_store(...)`. Działa lokalnie przez
**Ollamę + nomic-embed-text** (embeddingi). Zero chmury.

### 2. Learning loop — promocja/degradacja wzorców
Każde wykonanie subtaska zapisuje outcome:
- **szybko + sukces** → wzorzec **promowany**
- **wolno + retry + błędy** → wzorzec **flagowany**
- **>60% porażek** → auto-inwersja w **anti-pattern** („AVOID")
- **90-dniowy half-life** → pewność maleje, jeśli nie potwierdzona ponownie

Sprawdzasz to: `swarm_get_pattern_insights`, `swarm_get_strategy_insights`,
`swarm_get_file_insights`. Komenda `/retro` to podsumowuje po większej robocie.

### 3. CASS — cross-agent search (Twoja cała historia AI)
Przeszukuje sesje **wszystkich** agentów (Claude Code, Codex, Cursor, OpenCode…).
Zanim rozwiążesz problem od zera: `cass search "..." --robot` sprawdza, czy już
go rozwiązałeś gdzieś indziej.

---

## 🎛️ Komendy

Wpisujesz je w OpenCode (TUI/OpenChamber). Definicje w `command/*.md`.

### Warstwa pomysłów (przed kodem)
| Komenda | Co robi |
|---|---|
| `/profile` | **Warstwa 0** — wciąga Twój **pełny profil** (`profile/jakub/`) i destyluje go w `profile/founder-fit.md` (unfair advantages, energy map, anti-fit, kanały). Odpalasz **raz**, odświeżasz gdy życie się zmieni. |
| `/ideate "<domena lub cisza>"` | **Psyche** — czyta bundle + founder-fit, generuje pomysły pod **Twój** unfair advantage; fit-critic zabija te bez founder-fit. → `0-opportunity.md` w `~/Desktop/1-Projects/_ideas/<slug>/`. |
| `/validate "<pomysł>"` | **BizDev** — research z sieci, unit economics (z kosztem AI/user), product-fit + bezwzględny demon-inwestor. → `GO/KILL/PIVOT`, na GO `2-plan.md`. Flaga `--brutal` = ostrzejszy demon. |

### Kodowanie
| Komenda | Co robi |
|---|---|
| `/swarm "opis"` | Pełny przepływ (patrz wyżej). **Dla: feature, refactor 3+ plików, bug+testy.** |

### Wspierające
| Komenda | Kiedy |
|---|---|
| `/swarm-status` | Postęp działającego swarma: epic, subtaski, blokady, co gotowe do spawnu. |
| `/review` | Ad-hoc adversarial review brudnego diffa (reviewer + demon + UBS), bez zmian. |
| `/iterate "..."` | Pętla popraw→oceń aż przejdzie demona i testy (max 3 rundy). |
| `/parallel "a" "b"` | Znane, niezależne taski równolegle (gdy sam znasz podział). |
| `/worktree-task "..."` | Ryzykowna/równoległa robota w izolowanym git worktree. |
| `/retro` | Po swarmie: czego się nauczył system, anti-patterny, sync. |
| `/commit` | Bramka (typecheck+lint+testy+UBS, brak sekretów) → czysty Conventional Commit. |
| `/pr-create` | Push + PR ze strukturalnym opisem (przez `gh`; bez `gh` daje compare-URL). |

---

## 🛠️ Narzędzia (silnik)

| Narzędzie | Wersja | Rola | Krytyczne? |
|---|---|---|---|
| **swarm** | 0.63.2 | Silnik orkiestracji — wszystkie toole `hive_*`/`swarmmail_*`/`hivemind_*`/`swarm_*`. | ✅ rdzeń |
| **OpenCode** | 1.17.7 | Host agentów (TUI). OpenChamber to GUI nad nim. | ✅ rdzeń |
| **Ollama** | 0.30.9 | Lokalne embeddingi (`nomic-embed-text`) dla pamięci semantycznej. Usługa launchd w tle. | ✅ dla hivemind |
| **UBS** | 5.3.2 | Skaner błędów AI. Bramka jakości. | ✅ jakość |
| **CASS** | 0.6.16 | Cross-agent session search. | ⚪ opcjonalne (pomocne) |
| **gh** | 2.94.0 | GitHub CLI — automatyczne PR-y. | ⚪ dla `/pr-create` |
| **bash** | 5.3 | UBS wymaga bash ≥4 (macOS ma 3.2). | ✅ dla UBS |
| **bun / node** | 1.3.14 / — | Runtime pluginu i toolingu. | ✅ rdzeń |

UBS i CASS pochodzą z oficjalnych tapów Homebrew autora (Dicklesworthstone), MIT,
weryfikacja SHA.

---

## 🧩 Skille (wiedza na żądanie)

Agent **sam ładuje** skill, gdy zadanie pasuje do jego opisu — nie zaśmiecają
kontekstu na zapas (w przeciwieństwie do `AGENTS.md`, które jest zawsze obecne).
Natywny mechanizm OpenCode: `~/.config/opencode/skills/<nazwa>/SKILL.md`.

| Skill | Kiedy się odpala |
|---|---|
| `testing-patterns` | Testy do legacy/nieotestowanego kodu (charakteryzacja, łamanie zależności wg Feathersa, co testować w SaaS, unit vs integration vs e2e). |
| `root-cause-debugging` | Coś się wywala / flaky — systematyczne: reprodukcja → izolacja → hipoteza → fix **przyczyny** nie objawu. |
| `saas-security-review` | Zmiany w auth / billing / multitenancy — playbook OWASP w formacie atak→sprawdź→fix (IDOR, mass-assignment, forged webhooks, idempotencja…). |
| `customize-opencode` | (wbudowany w OpenCode) Edycja samego configu OpenCode. |

---

## 📚 Pliki wiedzy (`knowledge/`)

Ładowane przez referencję `@knowledge/<plik>.md` (gdy agent ich potrzebuje):

| Plik | Zawartość |
|---|---|
| `saas-patterns.md` | Uniwersalne wzorce SaaS: multitenancy, idempotencja, webhooki, billing, auth/sesje, kolejki/joby, migracje, API, observability. |
| `security-checklist.md` | Checklist OWASP: injection, authn/authz, sekrety, SSRF, rate limiting, concurrency, logowanie. |

Różnica od skilli: knowledge = **referencja** dociągana świadomie; skille =
**auto-wykrywane** po opisie. Oba ładowane na żądanie (nie na zapas).

---

## 📁 Struktura plików

```
~/.config/opencode/
├── opencode.jsonc        ← modele, provider (DeepSeek max + Kimi/MiniMax), MCP, uprawnienia
├── AGENTS.md             ← reguły dla WSZYSTKICH agentów (zawsze w kontekście)
├── agent/  (25)          ← warstwa kodu (16) + psyche-* (4) + biz-* (5)
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
└── plugin/swarm.ts       ← wrapper pluginu (absolutne ścieżki — GUI-safe)

~/Desktop/                  ← Twój pulpit zorganizowany w PARA (0-Inbox, 1-Projects, 2-Areas, 3-Resources)
├── 3-Resources/profile/
│   ├── jakub/             ← WARSTWA 0 — Twój pełny bundle (źródło prawdy, czytany wprost)
│   └── founder-fit.md     ← soczewka biznesowa (destyluje /profile)
└── 1-Projects/
    ├── _ideas/<slug>/     ← inkubator: 0-opportunity → 1-validation → 2-plan.md
    └── <slug>/            ← po GO pomysł AWANSUJE tu jako prawdziwy projekt (kod)

~/.local/share/opencode/auth.json   ← klucze deepseek + openrouter (⛔ NIE RUSZAĆ)
~/.config/opencode.backup-*         ← backup poprzedniego configu
```

**Dlaczego absolutne ścieżki w pluginie?** OpenChamber (GUI) startuje bez shellowego
PATH. Plugin woła CLI po pełnej ścieżce (`/opt/homebrew/bin/swarm`,
`/opt/homebrew/bin/opencode`) i prependuje `/opt/homebrew/bin` do PATH przy spawn —
żeby w GUI znaleźć `cass`/`ubs`/`ollama`/`bash5`.

---

## 🔑 Git / GitHub (skonfigurowane)

| Element | Stan |
|---|---|
| Protokół | **SSH** (klucz `~/.ssh/id_ed25519`, w ssh-agent + Keychain macOS) |
| Klucz na GitHub | `mac-m2-2026-06` (typ: authentication) |
| `gh` CLI | zalogowany jako **`mggpie`** (scope: repo, admin:public_key, …) |
| Tożsamość commitów | `mggpie <57095596+mggpie@users.noreply.github.com>` (no-reply — bez prywatnego maila) |
| Default branch | `main` |
| Fallback | `gh auth setup-git` ustawiony → HTTPS też działa, gdyby SSH padło |
| Test | `ssh -T git@github.com` → *„Hi mggpie! You've successfully authenticated"* ✅ |

`git clone`/`push`/`pull` po SSH działają — w tym **repo prywatne**. `/pr-create`
otwiera PR-y przez `gh`. Stary klucz `void` (z Linuksa) jest na koncie GitHub, ale
fizycznie nie ma go na tym Macu — nieistotny.

---

## 🍳 Przepisy — typowe sytuacje

**Pełny pipeline (od zera, od pomysłu do kodu):**
```fish
cd ~/Desktop/1-Projects/_ideas
/profile                               # RAZ: wciąga Twój pełny profil → 3-Resources/profile/founder-fit.md
/ideate "narzędzia dla solo-devów AI"   # → _ideas/<slug>/0-opportunity.md, wybierasz 1 pomysł
# przejrzyj brief, potem z 1-Projects/_ideas/<slug>/:
/validate "<wybrany pomysł>"            # → GO/KILL/PIVOT; na GO awansuje do 1-Projects/<slug>/ + 2-plan.md
# jeśli GO — w tym projekcie / repo kodu:
/swarm "<z 2-plan.md>"                  # buduje wedge
/commit  →  /pr-create
```
Większość pomysłów **umrze** na `/ideate` lub `/validate` — to cel. Tania śmierć
w konsoli > 3 miesiące kodowania czegoś, za co nikt nie zapłaci.

**Tylko walidacja gotowego pomysłu:**
```
/validate "SaaS do X dla Y" --brutal   # ostrzejszy demon + dodatkowa runda CFO
```

**Nowy feature:**
```
/swarm "dodaj eksport faktur do PDF z szablonem"
→ odpowiedz na 1-2 pytania (albo dodaj --fast)
→ patrz: architect planuje → workerzy piszą → demon szuka dziur → shipper
/commit  →  /pr-create
```

**Bugfix (z testem regresji):**
```
/swarm "napraw: webhook Stripe podwójnie nalicza przy retry (+ test)"
```
(strategia `risk-based` → najpierw failing test, potem fix przyczyny)

**Szybki przegląd przed commitem:**
```
/review        ← reviewer + demon + UBS na brudnym diffie, bez zmian
```

**Refactor po wielu plikach:**
```
/swarm "zmigruj wszystkie wywołania starego API klienta na nowy --worktrees"
```

**Po większej robocie — utrwal naukę:**
```
/retro         ← co zadziałało, jakie anti-patterny, sync
```

**Sprawdź, czy już to rozwiązywałeś:**
```fish
cass search "stripe webhook idempotency" --robot --limit 5
```

---

## 🔧 Diagnostyka

| Problem | Sprawdź |
|---|---|
| Config się nie ładuje | `opencode debug config` (zparsowany JSON albo błąd) |
| Agent nie widzi skilla | `opencode debug skill` (lista wykrytych) |
| Modele agentów | `opencode debug config \| jq '.agent'` |
| Zależności swarma | `swarm doctor` |
| Dostępne modele | `opencode models \| grep deepseek` |
| Ollama żyje? | `curl -s localhost:11434/api/version` |
| SSH do GitHub | `ssh -T git@github.com` |

> **UBS w `swarm doctor` pokazuje „not found"** — to **fałszywy alarm**. `swarm
> doctor` woła `ubs` przez `/usr/bin/env bash`, który w Twoim PATH trafia na
> macOS bash 3.2 (UBS wymaga ≥4). Agenci wołają UBS poprawnie przez
> `/opt/homebrew/bin/bash /opt/homebrew/bin/ubs` i **działa** (zweryfikowane —
> łapie błędy). Czysto kosmetyczne.

---

## ⛔ Czego NIE robić

- **Nie uruchamiaj `swarm setup`** — zregeneruje `plugin/swarm.ts` (skasuje fix
  `liteModel` na DeepSeek + wstrzyknięcie PATH dla GUI) i nadpisze `AGENTS.md`.
  Domyślnie ustawia opus/sonnet/**haiku** (haiku/anthropic nie masz w auth).
  Wszystko już działa bez niego.
- **Nie ruszaj `auth.json`** — tam są klucze API (deepseek + openrouter).
- **Nie commituj z `--no-verify`** — omija bramkę jakości. `/commit` tego pilnuje.
- **Pamiętaj o restarcie** — po zmianie w `~/.config/opencode/` zrestartuj
  OpenCode/OpenChamber (config ładuje się raz przy starcie, nie ma hot-reloadu).

---

## 📖 Słownik pojęć

| Pojęcie | Znaczenie |
|---|---|
| **Koordynator** | Główny agent sesji `/swarm`. Mózg — orkiestruje, nie pisze kodu. |
| **Worker** | Agent wykonujący jeden subtask w jednorazowym kontekście. |
| **Subtask / bead** | Atomowy kawałek pracy z granicą plików, śledzony w hive. |
| **Epic** | Zbiór subtasków = całe zadanie z `/swarm`, backed gitem. |
| **Rezerwacja (swarmmail)** | Worker „blokuje" pliki, które edytuje → brak konfliktów z innymi workerami. |
| **Demon** | Adwersarz (GLM 5.2) — próbuje złamać kod zanim wyjdzie. |
| **Hivemind** | Pamięć semantyczna (wektorowa) między sesjami. |
| **Learning loop** | System promocji/degradacji wzorców na podstawie outcome'ów. |
| **Anti-pattern** | Strategia auto-oznaczona jako zła (>60% porażek) → „AVOID". |
| **Worktree** | Izolowana kopia robocza gita (osobny branch) per worker. |
| **UBS** | Ultimate Bug Scanner — mechaniczny skaner błędów AI. |
| **CASS** | Cross-Agent Session Search — szukanie po całej Twojej historii AI. |
| **max thinking** | `reasoningEffort: max` — DeepSeek myśli maksymalnie od startu. |
| **read-only agent** | Agent z `edit: deny` — fizycznie nie może zmienić kodu. |
| **unfair advantage** | Przewaga, której konkurent nie skopiuje (rzadka kombinacja skillów, przeżycie, asset, sposób myślenia). Rdzeń warstwy Psyche. |
| **founder-market fit** | Czy ten konkretny założyciel udźwignie i wygra w tym rynku — i czy go to nie wypali. |
| **founder churn** | Śmierć biznesu, bo założyciel wypali się/znudzi (nie z powodu rynku). `anti-fit.md` przed tym chroni. |
| **COGS / unit economics** | Koszt obsługi 1 usera (w AI: tokeny/user!). Jeśli COGS ≥ cena → biznes krwawi. |
| **wedge** | Najmniejsza rzecz, którą zbudujesz najpierw, a już jest warta zapłaty. |
| **artefakt handoff** | `0-opportunity.md` → `1-validation.md` → `2-plan.md` — kontrakt między warstwami. |

---

*Wygenerowano: 2026-06-20 • OpenCode 1.17.7 + swarm 0.63.2 + OpenChamber*
*Pipeline: `/ideate` (Psyche) → `/validate` (BizDev) → `/swarm` (Code) — ten sam silnik, 3 warstwy*
