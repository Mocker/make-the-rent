# Zoud GameLab — Narrowed Design v2

**Supersedes the breadth in v1** (`CONCEPT_AND_SUBMISSION_PACK.md` §1–§2). The pack outline, budget, video and disclosure sections in v1 still stand, updated as noted in §7 below.
**Basis:** Serverpod "Build Something Real" winners, verified Oct 22 — `winners-patterns.md` + `judge-signals-brief.md` in the hackathon-season goal. ~200 entries, 5 placed.
**Date:** Oct 23, 2026

---

## 0. What the winners actually taught us

| # | Winner signal (evidence) | What it kills in v1 |
|---|---|---|
| 1 | **One concrete non-technical user, one everyday frustration.** Garden (Mac users with full disks), BenchCall (pickup-sports organisers drowning in group chats), Did It Stick? (parents stuck on maths homework). No dev-infra entry placed, even at a developer-framework hackathon. Judges' own tip: *"small and finished rather than huge and broken."* | "Ages 18–28 first renters, plus classrooms, plus family play" — three audiences is no audience. 7 FinLit concepts is a curriculum, not a game. |
| 2 | **Depth over breadth in a narrow slice.** Dream League won craft for offside rules, cards, penalties, difficulties *inside one game*. BenchCall for a backup-player cascade + money-splitting *inside one organiser flow*. | 12 weeks × 18 choice cards × 10 random events × 10 props × 4 meters = everything thin. Random events also destroy learnability — you can't learn from dice you can't anticipate. |
| 3 | **Nothing faked, completeness is the tiebreaker.** Serverpod rubric: 30% "does it work — it runs, the core flow completes, nothing critical is faked," explicit tiebreaker. | 5 character motions, prop state-swaps for 10 props, mood system — polish spread across surfaces that can each break. Fewer surfaces, all of them finished. |
| 4 | **Frictionless judge path.** BenchCall praised on the announcement page for "works directly in the browser… try it without signing up." Dream League had a no-account practice mode. | A 15–18 minute run is judge friction. A judge who doesn't finish doesn't score Educational Impact or the ending. |
| 5 | **Coach, don't answer + a personally-felt story.** Did It Stick? won in part because judges "love that it focuses on helping people learn, rather than just making the homework disappear." EmergencyHr won Best Post on a true, specific human story. | v1's Journal *told* the player the lesson after each choice ("Debt interest outruns savings interest"). That's a lecture wearing a journal's clothes. |

Zoud's own rubric reinforces #5 directly — Educational Impact rewards games where players *"explore consequences, experiment and learn from decisions"* and *"reconsider assumptions,"* not games that explain at them.

---

## 1. The narrowed game

### RENT DUE! — One Month, Run It Back

**One user:** **Alex, 23, café barista with variable shifts, first solo apartment.** Not "young people." Alex. One named frustration:

> *"I get paid and feel fine. Then one thing goes wrong, it goes on the card, and rent week is panic — every single month."*

**One learning outcome** (the whole game exists to teach this one sentence, by experience):

> **A small buffer, built on payday before spending starts, turns a $200 shock from a debt spiral into an inconvenience — even when your pay changes week to week.**

Everything that does not serve that sentence is cut. See §5.

**One month, not twelve weeks:** 4 paychecks. **One complete run: ~5 minutes.** Rent is due at the end of Paycheck 4.

### The innovation: Run It Back

The month is **deterministic** — same pay, same shocks, same order, every run.

1. **Run 1 — Blind.** Play the month. Most players will put the Week 2 shock on the card, meet the Week 3 short paycheck with no cushion, and scrape or miss rent. The game never says what they *should* have done.
2. **The Reveal (30 seconds).** One screen, no lecture: a timeline of the month showing the *three moments money moved* — what the shock actually cost on the card vs. what it would have cost from a buffer (shown as two numbers, side by side, no adjectives).
3. **Run 2 — Same month, on purpose.** The prominent button is **"Run It Back — same month, your call."** Same pay, same shocks. The player now splits their first paycheck differently *because they know what's coming* — which is exactly what a real buffer is for in a life where shocks are not random, they're just unscheduled.
4. **Comparison, not a grade.** End screen shows Run 1 vs Run 2 side by side: rent paid?, card balance, buffer left. The improvement is the player's own evidence. A one-line prompt from the game — *"What did you change?"* — with three tappable self-descriptions (e.g. "I fed the jar first" / "I skipped a want" / "I still used the card — but less"). Their words, not the game's lesson.

This is Did It Stick?'s coaching stance turned into a mechanic, and it's the direct answer to Zoud's "experiment and learn from decisions" criterion. It's also genuinely hard to copy, because it requires the deterministic month + comparison design, not just a theme reskin.

**Practice mode (judge path + accessibility):** Week 1 can be played as a no-fail practice payday before Run 1 starts — Dream League's no-account practice pattern. One tap from the title screen to playing. No signup, no tutorial text wall.

---

## 2. Only three verbs

The entire game is three interactions. Each is deep; nothing else is interactive.

### Verb 1 — SPLIT (every payday, the core interaction)
The paycheck lands as a pile of cash on the table. The player drags (or taps-to-place, for accessibility) money into **three containers only**:

- **Rent Tin** — locked until rent day. Money in cannot be spent. (Teaches: separating rent money is a physical act, done once, on payday.)
- **Buffer Jar** — the hero prop. Accessible *only* when a shock hits.
- **Week Cash** — everything else lives here: food, fun, regular bills auto-leave from Week Cash each week.

Depth inside this one verb (the Dream League "rules" layer):
- Rent Tin short at rent day triggers the **cascade** (§2, Verb 3).
- Week Cash can go to $0 mid-week — then one small want card is greyed out with "Week Cash empty," felt, not explained.
- There is **no "correct split" shown, ever.** No percentages, no recommended allocation, no green checkmarks. Run It Back is how the player finds their split.

### Verb 2 — CHOOSE (one dilemma per week, 4 total, each with downstream consequences)
Not 18 cards. **Four dilemmas, each written deep, each consequence landing 1–2 weeks later** (BenchCall's cascade-style depth: decisions propagate).

| Week | Dilemma | Options (all defensible) | Delayed consequence |
|---|---|---|---|
| 1 | Friends' group gift + night out, $60 | Go / Go cheaper ($25, say so) / Skip | Go: Week Cash tight in Wk 2. Cheaper: nothing bad — social honesty works. Skip: +$60, a quiet apartment beat (mood shown by the *room*, no meter) |
| 2 | **The Shock: bike breaks, $180** — Alex's transport to work | Fix now from Buffer or Week Cash / Put on card / Don't fix, take the bus (+time, −$8/wk bus fare, one late-shift risk event in Wk 4) | Card: interest + minimum payment auto-deducted from Paycheck 3. Bus: smaller, ongoing leak. Buffer: jar visibly cracks-then-holds — the hero moment of Run 2 |
| 3 | Paycheck is **short: shifts cut, −$140** (fixed, announced only when it lands in Run 1; known from the start in Run 2) | — (this is not a choice, it's the test the month was built around) | Players with no buffer meet this with the card already loaded from Wk 2 — the spiral, experienced, not described |
| 4 | Phone screen cracks, $90, rent is in 3 days | Fix from Week Cash if it survives / Card / Live with the crack (free; phone prop stays cracked in the end screen — a kept receipt of a good decision) | Putting rent at risk for a phone is the final temptation; the game trusts the player to have learned |

### Verb 3 — ABSORB or CHARGE (only when a shock hits)
A shock presents exactly two big buttons: **Pay from Buffer** (jar drains, done) or **Put It On The Card** (fast now). If rent day arrives with the Tin short, the game runs the **Shortfall Cascade** in the open, step by step, player confirming each step. Rent settles against the Tin first; any shortfall cascades:

1. Pull what's in the Buffer Jar →
2. Pull remaining Week Cash →
3. If that's still not enough: **Rent Short** end state (see endings).

Rent is paid by bank transfer — **the card never covers rent** (mechanics change, approved Oct 23). The card still absorbs shocks and essentials overflow, but money sitting on the card can't pay the landlord, so where the money sits matters: absorbing a shock from cash can put rent at risk in a way charging it doesn't, and vice versa.

No hidden maths. Every number is on a prop or a container, in dollars, in the open. The cascade *is* the financial system, visualised — this replaces v1's four meters entirely.

### Rules layer (depth, stated once in the GDD, never lectured in-game)
- Card interest: a flat, legible **$12 per $100 owed, per month boundary crossed**, applied visibly as the card prop heats. Labelled in-game and in the GDD as *simplified for play*.
- Card minimum payment: **$25 or the full balance if less**, auto-deducted at Paychecks 3 and 4 if a balance exists. This is the trap, made mechanical: a Week 2 decision eats Paycheck 3 before the player touches it.
- Buffer Jar earns **nothing**. Deliberate design statement, stated in the GDD: a first buffer's job is absorption, not growth. (Kills v1's misleading "savings earn a little" framing — a $600 buffer's interest is trivial and teaching otherwise is inaccurate.)

### Endings (3, all complete, none shaming)
- **Rent Paid + Buffer Left** — best ending. Jar glows, room warm.
- **Rent Paid, On The Card** — rent covered, but the end screen shows the minimum payment waiting in *next* month. A qualified win, honestly labelled.
- **Rent Short** — landlord note on the door prop. The Journal-equivalent (see §3) shows the exact cascade that fell short, and the primary button is Run It Back. Failure is a rehearsal invitation, not a verdict.

---

## 3. What replaces the Journal

v1's weekly lecture line is cut. In its place, **The Reveal + three tappable self-descriptions** (§1) and one artefact: **The Month Timeline**, a single horizontal strip (also the video's money shot and the GDD's worked example) showing, for each run, the four paydays, the two shocks, and where the money actually was when each shock hit. Educational evidence a judge can *see in one image*.

---

## 4. Presentation — fewer props, finished properly

**Room stays the visual language** (the one v1 idea worth keeping), narrowed hard:

**6 props, each with real state work (was 10):**

| Prop | States | Why it survives the cut |
|---|---|---|
| **Buffer Jar** (hero) | 5 fill levels + crack overlay after a shock-absorb | The game's thesis, in glass |
| **Rent Tin** | Fill line vs. rent target line — always visible | The goal, never off-screen |
| **Card (oversized, on table)** | Cool / warm / hot-cracked (3 heating states tied to balance bands) | The cost of the alternative, ambient |
| **Fridge** | Full / low / empty (Week Cash for food made visible) | Needs vs wants, without a card deck |
| **Bike** | Working / broken (Wk 2 shock) / bus pass on table instead | The shock has a face |
| **Phone** | Normal / cracked (kept crack = badge of the Wk 4 decision) | A receipt the player chose |

Cut props: plant, piggy bank, laptop, sofa, wall calendar, mail pile, lamp. (Calendar function moves to a simple "Rent in N paychecks" counter in the Rent Tin itself.)

**Character (rig2d): 3 motions, finished, not 5 sketched** (per Ryan's Oct 21 rig2d workflow rule: each animation is designed conversationally first — what moves, how far, timing, what must NOT move — then authored and GIF-reviewed; no generic presets):
- `idle` — breath + blink, the baseline the judge sees 90% of the time; this one must be *good*
- `payday_split` — hands move to containers as the player splits; character's hands follow the player's verb, which sells Verb 1
- `shock_react` — one flinch-and-look at the broken bike/card, used at both shocks and nowhere else, so it keeps its meaning

Cut motions: `celebrate`, `sleep`, `worried` as separate clips — celebration is the *room's* job (jar glow, warm light), worry is shock_react reused.

**Judge path:** Browser, itch, click Play → title → **one tap → practice payday or straight into Run 1**. Full experience (both runs) ≈ 11 minutes; a judge who only does Run 1 still gets a complete game with an ending in ~5. Nothing faked: both runs, all three endings, the cascade — all implemented, because the scope finally fits the window.

---

## 5. KEEP / SHARPEN / DROP (from v1)

**KEEP**
1. Room-is-balance-sheet as visual language. It's the creative hook (Zoud Creativity, 15 pts).
2. Flutter web on itch, no download, no signup.
3. Numbers round and legible; "simplified for play" labelled in-game and in GDD.
4. Accessibility basics in MVP (tap-alternative to drag, captions, no timers, colourblind-safe — state shown by fill level and icon, not colour alone).

**SHARPEN**
1. Audience: 18–28-everyone → **Alex**. Marketing/GDD story is now one person's month, drawn from a recognisable life (variable shifts), not a demographic.
2. Teaching: Journal lectures → **Run It Back + The Reveal**. Coach, don't answer.
3. Video: the money shot is now obvious — the same $180 shock, Run 1 (card, heats, eats Paycheck 3) vs Run 2 (jar absorbs it, month survives). Same footage structure as v1 §4C, but now the game itself produces the contrast.
4. Commercial story (20 pts): one perfect month is a *stronger* funding case than a thin year — funded work is "Alex: First Car" and "Alex: College" as new *months* on the same proven loop, plus school licensing of a 15-minute, two-run classroom activity (fits a single lesson period — a concrete, checkable claim).

**DROP**
1. 12-week structure, 18 choice cards, 10 random events, Mood meter, subscription-creep system, income-volatility system as separate mechanics (volatility survives as the fixed Week 3 short paycheck — as a *designed test*, not a system).
2. "Savings earn a little" — inaccurate at this scale, cut (§2 rules).
3. Five motions / ten props — cut to three / six (§4).
4. AED toggle as a stretch goal — it was cosmetic. It moves to the funded localisation roadmap in the GDD only, honestly labelled (unchanged from v1 §5's honest position).

---

## 6. Revised scope & timing impact

- Content to write: 4 dilemmas, 2 shocks, 3 endings, 1 reveal screen, 1 comparison screen. (v1: ~28 cards + journal lines.)
- Art to produce: 6 props with states, 1 character, 3 motions.
- Systems to code: split, dilemma consequences (flagged, delayed), absorb/charge + interest/minimum, shortfall cascade, deterministic replay + run comparison. All of it one state machine over one month.
- This fits **after** the existing schedule pressure more safely than v1, and the "submit Nov 14" target in v1 §3 stands unchanged. The Oct 22–25 asset batch, if it proceeds, should now batch the §4 list only.

## 7. Required edits to v1 pack (do not let the docs disagree)
- §1 concept → replace with this file's §1–§2.
- §4B GDD outline: learning outcomes = the single outcome (§1) + evidence from Run 1 vs Run 2 comparison design; worked example = The Month Timeline.
- §4C video: rebuild around the Run 1 / Run 2 shock contrast (§5 SHARPEN 3).
- §4D budget: unchanged total logic; reword deliverables from "2 new seasons" to "new months (First Car, College) on the proven loop + classroom licensing pack."
- §4E AI disclosure: unchanged (finalise against what is actually used).
