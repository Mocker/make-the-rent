# RENT DUE! — Game & Design Review vs the Zoud GameLab Jam

**Date:** 2026-11-09 · **Scope:** game completeness, financial-education delivery, and jam readiness.
**Assets excluded by instruction** (art is placeholder by design; rig2d is paused). Where a *system* behind an asset exists in code (jar fill levels, card heat bands), the system is scored; the picture is not.
**Design authority:** `NARROWED_DESIGN_V2.md` (adopted Oct 23), as amended by `REALISTIC_ECONOMY_PROPOSAL.md` (approved numbers + card-out-of-cascade addendum). `CONCEPT_AND_SUBMISSION_PACK.md` is the v1 pack; its §1–§2 are superseded by v2, its submission sections stand subject to v2 §7 edits.
**Code audited:** `game/lib/game_model.dart` (351 lines), `game/lib/main.dart` (882 lines), `game/test/` (2 files).

---

## 1. Build verification (run 2026-11-09, Flutter 3.47.7 / Dart 3.13.5)

| Check | Command | Result |
|---|---|---|
| Analyze | `flutter analyze` | **Clean — "No issues found!"** (dependencies resolved; re-confirmed with `flutter analyze --no-pub`, 1.8 s) |
| Tests | `flutter test --no-pub` | **17/17 passed** — 16 model tests (interest, minimum payment, split/essentials, shocks, cascade ×3, three endings via full deterministic playthroughs, determinism double-run) + 1 widget test (title screen + both entry points) |
| Web build | `flutter build web --release --no-pub` | **Success** — compiled in 51.2 s; `build/web/main.dart.js` 2.1 MB, fresh 2026-11-09 build replaces the Oct 24 one |

The game that exists is stable and shippable as a binary. Nothing in this section is a blocker.

---

## 2. Feature inventory vs design v2 promises

Evidence: M = `game_model.dart`, U = `main.dart`, T = tests.

| # | Design promise | Verdict | Evidence |
|---|---|---|---|
| 1 | Title screen with the $900 below-market studio story line | **PRESENT** | U:263–283 — "RENT DUE! / One Month, Run It Back", Alex intro ("Rent is $900, due after the fourth paycheck"), and verbatim: *"The place is an older studio a few blocks from the café — $900 is less than most places nearby ask."* |
| 2 | Practice mode — Week 1 only, no-fail, one tap from title | **PRESENT** | U:286 "Practice Week 1" button → `_startRun(1, practiceMode: true)`; after the Week 1 event, flow routes to `practiceEnd` (U:_afterWeekEvent) → "Practice done / That was one week. The full month is four." No fail state exists in Week 1, so no-fail holds. |
| 3 | SPLIT steppers — allocate every dollar, no suggested split | **PRESENT** | M:150–157 `applySplit` rejects any split whose sum ≠ net paycheck. U:_split steppers (±$10/±$50 buttons, clamped to the paycheck) and the confirm button is **disabled until remaining == 0** ("Split it (put every dollar somewhere)"). No suggested/recommended split exists anywhere (see #14). |
| 4a | W1 dilemma — night out Go $60 / cheaper $25 / Skip $0 | **PRESENT** | M:200–210; U:_nightOut three buttons with the social-honesty framing ("Going cheaper — $25 — means saying so out loud"). |
| 4b | W2 shock — bike $180: absorb / charge / bus | **PRESENT** (superset) | M:213–241; U:_bike offers **four** options: Buffer Jar, Week Cash, Card, Bus ($30 pass now + $45 late fee in W4). Design's dilemma table lists buffer/card/bus; the Week Cash option is an addition — it is also what makes the cash-absorb Rent Short line possible. Buffer/Cash buttons disable with an explanatory label when the source can't cover $180. Bus sets `busLateFeePending`; the fee lands in W4 before the phone shock (U:_roomContinue, case 4). |
| 4c | W3 — short paycheck + side gig | **PRESENT** | M:68 paychecks `[455, 470, 380, 460]` — W3 is $90 under W2. Split screen states it when it lands: *"Shifts were cut. This paycheck is $90 smaller than last week's."* Gig: M:253–260, +$50 net; U:_gig discloses "+$80 pay, −$30 costs. Net +$50" before the choice. |
| 4d | W4 shock — phone screen $90: fix from cash / charge / live with crack | **PRESENT** | M:263–278; U:_phone three buttons. `cracked` sets `phoneKeptCracked`, surfaced on the ending screen: *"The phone is still cracked. It still works."* — the design's "kept receipt." Caveat in §4. |
| 5 | Interest $12 per full $100 at start of W3 & W4; $25 minimum (or full balance if less) auto-deducted from paychecks 3 & 4 | **PRESENT** | M:82 `interestFor = (balance ~/ 100) * 12`; M:128–146 `startWeek` applies interest **then** minimum, only in weeks 3–4 and only if a balance exists; net paycheck = gross − minimum. Covered by 4 dedicated tests, incl. interest-before-minimum ordering ($180 → +$12 → −$25 → net $355). Split screen discloses both lines before the player splits (U:_split). |
| 6 | Essentials $160/wk, itemized in UI | **PRESENT** | M:71 `weeklyEssentials = 160`; U:_split lists Groceries $75 / Utilities $42 / Phone $13 / Bus pass $12 / Laundry & toiletries $18 (= $160) with *"If Week Cash is short, the rest goes on the card."* M:164–176 overflow goes to the card and the room screen reports the exact overflow amount. |
| 7 | Player-stepped Shortfall Cascade, "card can't cover rent" line | **PRESENT** | M:286–320 plan is Jar → Week Cash only — there is no card step, and tests assert the card balance is untouched by the cascade. U:_cascade shows the plan as a checklist and moves **one step per button press** ("Move $X from Buffer Jar"), then "Settle rent". Copy is verbatim: *"Rent is paid by bank transfer — the card can't cover rent."* (U:540) plus the order stated up front. If the tin is already full, the cascade is correctly skipped (U:_rentDay). |
| 8 | Three endings — Nothing Owed / On The Card / Rent Short | **PRESENT, all reachable** | M:331–336 classification (not paid → rentShort; paid + balance > 0 → onTheCard; paid + $0 → nothingOwed; buffer amount deliberately does **not** gate the best ending, per the realistic-economy amendment). Tests prove each ending via a distinct full playthrough: careful → Nothing Owed (card $0, buffer $20, interest $0); careless → On The Card (card $244, interest $24); cash-absorb → Rent Short ($795 of $900). A maximum-spiral line also lands On The Card (card $902) because its money sat in the tin — documented in the test itself. U:_ending adds the honest qualifier for On The Card: next month's minimum payment "already waiting." |
| 9 | The Reveal — numbers-only | **PARTIAL** | U:_reveal ("The numbers") shows four aggregate rows: shocks put on the card, interest added, their total, shocks paid from the Buffer Jar. No adjectives, no lecture — the numbers-only discipline holds. **But** design v2 §1/§3 specifies the Reveal as *The Month Timeline* — the per-moment strip of where money was when each shock hit — plus a side-by-side contrast (shock cost on card vs from buffer). Neither exists: the model **builds** a full `timeline` list for every event (M:timeline, carried into `RunSummary.timeline`) and the UI **never renders it** (`grep timeline lib/main.dart` = no matches). The counterfactual contrast is also absent — the player sees what the card cost in total, not "this $180 shock cost you $180 + $24" next to "$180". Biggest single design-vs-build gap in the game. See §5. |
| 10 | Run It Back — identical deterministic month, Run 2 | **PRESENT** | No randomness anywhere in `lib/` (no `Random`/shuffle; all numbers are constants). A test runs the careful month twice and asserts identical ending, balances, and timeline. Reveal's primary button: *"Run It Back — same month, your call"* → Run 2; Run 2's ending routes to Comparison instead of Reveal (U:_endingContinue). |
| 11 | End comparison — rent paid?, final card balance, buffer left | **PRESENT** | U:_comparison table: Rent paid (Yes/No), Card balance, Buffer left — plus a bonus row the design didn't require, Interest paid. Run 1 vs Run 2 side by side. |
| 12 | "What did you change?" self-description chips | **PRESENT** | U:_comparison — the three designed chips verbatim: *"I fed the jar first" / "I skipped a want" / "I still used the card — but less"*, single-select `ChoiceChip`s, response is *"Noted. It's your month."* No grading, no correct answer. |
| 13 | Practice → full-month on-ramp | **PRESENT** | Practice end offers "Play the full month" and "Back to title" (U:_practiceEnd). |
| 14 | NO "correct split", recommended percentages, or green checkmarks anywhere | **VERIFIED ABSENT** | `grep -i "correct\|recommend\|ideal\|you should" lib/` returns nothing; no percentage allocation is shown anywhere. Two near-misses that are **not** violations, noted so they aren't misread: (a) the cascade checklist uses a filled check-circle icon for steps *already executed* — progress state, not correctness judgement; (b) `ChoiceChip` shows a check on the player's *selected self-description* — selection state, not approval. The split screen states only facts (lock rule, $900 goal). |

**Inventory score: 12 present, 1 present-as-superset (4b), 1 partial (Reveal), 0 missing outright.**

Smaller design details not implemented (low impact, recorded for honesty):
- Design v2 §2's "Week Cash hits $0 → a want greys out" micro-beat: no separate want card exists to grey out; the night-out choice instead overflows to the card (see §4 nit). The *feeling* (cash scarcity) survives via essentials overflow messaging.
- Design's "Rent in N paychecks" counter inside the Rent Tin: implemented as a text line in the room ("rent due after paycheck 4" + progress bar + $x of $900), functionally equivalent.

---

## 3. Complete-experience check

**Full loop traced through the phase machine** (U:Phase enum, 10 phases, every phase has a widget and an exit):

Title → Split W1 → Room → Night Out → Split W2 → Room → Bike → Split W3 → Room → Gig → Split W4 → Room (bus late fee auto-applies here if owed, with an explanatory note carried into the phone screen) → Phone → Rent Day (tin full → settle directly; short → stepped Cascade → Settle) → Ending → **[Run 1]** Reveal → Run 2 (same 4 weeks) → Ending → Comparison → Back to title / Play again. Practice branches Title → W1 → Practice End → full month or title.

- **Dead ends: none found.** Every button in every phase is wired; the only disabled buttons are intentional gates with explanatory labels (Split until fully allocated; Bike buffer/cash when insufficient). All state transitions are in `_roomContinue` / `_afterWeekEvent` / `_rentDay` and cover weeks 1–4 exhaustively.
- **TODOs / debug text / unwired UI: none in `lib/`** (grep for TODO/FIXME/debug = the word "placeholder" in one code comment about the Alex image — an asset note, out of scope here). No stray default Flutter counter-app remnants in the game itself.
- **Boilerplate outside the game (cheap hygiene):** `game/README.md` is still the default "A new Flutter project" template, and `game/web/index.html` still has `<title>rent_due</title>` and meta description "A new Flutter project." The itch page will frame most of this, but the browser tab title is judge-visible.
- **Playthrough duration (estimated, not measured — no live playtest was run for this audit):** Per run: 4 splits + 4 room continues + 4 event choices + cascade (0–2 steps) + ending. The splits dominate: allocating ~$355–$470 per week with ±$10/±$50 steppers across three containers takes roughly 45–90 s per week once learned, longer on first encounter. **Run 1 ≈ 4–6 min, both runs ≈ 9–13 min** — consistent with the design targets (~5 min / ~11 min) and with the judge path (a judge who stops after Run 1 + Reveal still gets a complete arc with an ending). **Pacing risk:** stepper tedium is the one friction point; it is a deliberate consequence of "no suggested split," but only a real playtest can say whether it reads as *deliberate* or *slow*. Flagged in the finish plan as test-and-decide, not as a defect.

---

## 4. Financial-literacy quality

**Single learning outcome** (buffer built on payday turns a shock into an inconvenience): **taught mechanically, and only mechanically.** The Week 2 bike is the lesson: the jar must already hold $180 *before* the shock, which is only possible if the player fed it in Weeks 1–2 *before* spending — exactly the target behaviour. Run 1 makes the failure mode felt (card → interest +$12 → minimum −$25 out of Paycheck 3 *before the player can split it* — the design's "a Week 2 decision eats Paycheck 3" trap, implemented literally at M:134–144); Run 2 lets the same player convert it, deterministically, into a non-event. That is learning through consequence and re-experiment, which is what the rubric's Educational Impact line rewards.

- **Lecture/quiz creep: none.** There is no journal, no quiz, no post-choice explanation. The only persistent text is a factual rules footer on every screen (U:164): *"Card interest is simplified for play: $12 per $100 owed, applied at the start of Weeks 3 and 4. The Buffer Jar earns nothing."* Choices are described in costs and facts, never morals. The ending screens report numbers; the Rent Short ending's primary path is back into the game (via Reveal / Run It Back), not a verdict.
- **Honesty of the card model: mostly strong, one inconsistency.** The "simplified for play" label is in-game (footer + model comments) and in the GDD draft, as required. Interest and minimum-payment amounts are disclosed on the split screen *before* the player allocates, and essentials overflow is announced with the exact dollar amount. **However:** the $500 card limit is enforced only in `chargeToCard` (M:180). Essentials overflow (`applyEssentials`, M:173) and interest (M:136) add to the balance *uncapped* — the maximum-spiral test ends at a **$902 balance on a "$500 limit" card**, with no over-limit state, fee, or explanation in the UI. A financially literate judge can spot this. Either cap-and-explain or document it as deliberate ("essentials and interest can exceed the limit; new charges cannot") — right now it is neither.
- **Transparency nits (small, fixable):** (a) Night Out and Phone "from Week Cash" silently overflow the remainder onto the card (`_payFromWeekCashOrCard`, M:187–197) — the button doesn't say so in advance, unlike the Bike screen, which disables unaffordable sources. The player discovers it from the next room's card line. (b) The W3 gig's only cost is opportunity ($0 for resting) — fine per design, but it makes "take it" close to dominant once rent math is understood; acceptable in a teaching game.
- **Does the Reveal surface cause and effect? Partially** — see #9. In-the-moment causation is well surfaced (interest/minimum lines on the split screen, overflow lines on the room screen, the stepped cascade). The *retrospective* artefact that would tie it together in one image — the Month Timeline — is recorded by the model and never shown. The Reveal's aggregates (shock-on-card + interest vs jar-paid) gesture at the contrast but don't isolate the $180 shock as the design's money shot requires.
- **Realism grounding:** paychecks ($1,765/mo), the $900 below-market studio (51% of take-home), and itemized essentials are sourced in `REALISTIC_ECONOMY_PROPOSAL.md` (Oregon $15.55 standard wage, Eugene rent ranges, USDA Thrifty). Monthly slack is $225 against $270 of shocks — the tightness is the curriculum, and it is real-world tightness, not arcade punishment. This grounding only helps scoring if it is *surfaced* in the GDD/itch copy (see §6).

---

## 5. Rubric map

| Rubric line | Points | Rating | Evidence (one line each) |
|---|---|---|---|
| Prototype & Gameplay | 25 | **Strong** | Complete deterministic loop, all 3 endings test-proven reachable, analyze clean, web build succeeds, no dead ends, judge path is one tap to Practice or Run 1. Only drag: stepper pacing (untested with humans). |
| Financial Literacy Integration | 25 | **Strong** | Every verb is a financial decision (split / absorb-or-charge / cascade); interest, minimum payment, essentials overflow, and the bank-transfer rent rule are all mechanics, not text. Held back from unqualified: the uncapped-balance inconsistency (§4). |
| Development & Commercial Potential | 20 | **Adequate** | The expansion story is credible and written down (new *months* — First Car, College — on the proven loop + a 15-minute two-run classroom activity; $42k milestone budget draft exists). But it currently lives in an internal pack, not in a submission-ready GDD, and the pack still carries v1 wording v2 §7 ordered changed. |
| Educational Impact | 15 | **Adequate** (one fix from Strong) | Run It Back + self-description chips are precisely the "experiment, reconsider assumptions" pattern the rubric rewards, with zero quiz/lecture. The missing Month Timeline / counterfactual in the Reveal is the difference between the player *feeling* the lesson and *seeing* it in one artefact. |
| Creativity & Innovation | 15 | **Adequate** | "Run It Back" — a deterministic month replayed with foreknowledge as the teaching mechanic — is genuinely distinctive and hard to reskin. The room-as-balance-sheet system layer is implemented (jar fill 0–5, card Cool/Warm/Hot bands, fridge bars, rent progress — all state-driven), though its visual expression is out of this audit's scope. |
| Bonus: Inclusivity & Accessibility | up to +5 | **Partially claimable** | See checklist below — the structural items are genuinely true of the build; don't overclaim beyond them. |
| Bonus: UAE / Arab localisation | up to +5 | **Not claimable** | No AED toggle and no Arabic in the build (design v2 deliberately moved this to the funded roadmap). The pack's honest position — professional localisation + interest-free variant as funded work — is the right one; claiming points now would contradict it. |

### Accessibility MVP checklist (from the pack §2/§5) vs the build

| MVP item | True of build? | Evidence |
|---|---|---|
| Browser play, no download | **Yes** | Flutter web release build verified; itch-embeddable output in `build/web/`. |
| No signup / no account | **Yes** | No auth, no backend, no storage calls anywhere in `lib/`. |
| Tap alternative to drag | **Yes — stronger than promised** | There is no drag at all. Splits are ±$10/±$50 **buttons**; every action is a full-width button or chip. |
| No timed inputs | **Yes** | No timers gate any input; the only animation loop is Alex's cosmetic breathing scale. |
| Captions for audio cues | **Vacuous — do not claim as a feature** | The game has no audio at all (no audio deps in `pubspec.yaml`, no sound code). Nothing needs captioning; the honest GDD line is "no audio cues to miss." |
| Colourblind-safe: state by fill/icon/label, not colour alone | **Mostly yes** | Card = colour band **+ "$ balance + Cool/Warm/Hot word"**; Jar = fill height **+ "$ + level n/5"**; Fridge = bars **+ Empty/Low/Stocked/Full word**; Rent = progress bar **+ "$x of $900" text**; Cascade steps = icon **+ text amounts**. Redundant encoding is systematic, not incidental. |
| Keyboard / screen-reader support | **Not verified** | All interactions use standard Material widgets (buttons, chips, list tiles), which carry Flutter's default focus/semantics on web — but there are no explicit `Semantics` labels in the code and no screen-reader pass has been done. Cannot be claimed beyond "standard-widget defaults." |
| Simple language by default | **Yes** | All copy is short, concrete, dollar-denominated; no jargon is used without being enacted (interest/minimum are shown as line items when they happen). |

---

## 6. Submission gaps — what exists vs what's missing

Development-funding consideration requires four things: **the game, a Concept Doc/GDD, a 2-minute video of actual gameplay, and a Game Budget.** Status:

| Item | Status | Detail |
|---|---|---|
| (a) Game build for itch | **Build ready; upload/submission NOT VERIFIED** | Fresh release build exists at `game/build/web/` (Nov 9). The public repo `Mocker/make-the-rent` mirrors game + docs. **No evidence in the workspace** of: an itch project page, an uploaded build (no `.zip` of the web build exists under `zoud-gamelab/` or the repo), an itch URL recorded in any doc (the only itch reference anywhere is the jam's own URL in the pack), or a completed jam submission. This audit cannot verify live itch state — treat upload + jam-submission as **not yet done** until checked in a browser. |
| (b) GDD / Concept Doc | **MISSING as a standalone document** | Searched `~/workspace/zoud-gamelab/` and `~/workspace/your_files/` for GDD/concept-doc/budget/disclosure files: **none exist.** The raw content is ~90% present across `NARROWED_DESIGN_V2.md` + pack §4B outline + `REALISTIC_ECONOMY_PROPOSAL.md`, but the pack is a v1 document whose §1–§2 are superseded, and v2 §7's required edits (single learning outcome, Month Timeline as the worked example, budget deliverables reworded to "new months", video rebuilt around the Run 1/Run 2 contrast) **have not been applied anywhere**. Assembling the 6–8 page PDF is editing work, not new writing. |
| (c) 2-minute gameplay video | **MISSING** | No video file (`.mp4/.webm/.mov`) exists anywhere in the project or repo. The pack §4C storyboard is **v1's** (12 weeks, Journal, $600 buffer) and does not match the shipped game; v2 §7 requires rebuilding it around the same $180 shock in Run 1 (card, heats, eats Paycheck 3) vs Run 2 (jar absorbs it). Must be *actual gameplay* footage per jam rules. |
| (d) Game Budget | **Draft EXISTS — confirmed** | Pack §4D: $42,000 total, 8 line items (design/engineering $18k; art $7k; FinLit consultant $4k; Arabic localisation $5k; accessibility audit $3k; audio $2k; QA $2k; pilot $1k) with 4 milestones. Needs the v2 rewording (deliverables = new months + classroom pack, not "2 new seasons") and extraction into whatever standalone form the submission requires. |
| (e) AI disclosure | **Draft EXISTS — must be finalised against the shipped build** | Pack §4E has judges-only draft wording with an explicit warning to delete unused tools. That warning bites here: the current shipped UI uses **one** image asset (`assets/alex.png`) and widget-drawn room graphics; the Blender prop renders and both rig2d rigs exist as project assets but are **not wired into the game** (pubspec declares only `alex.png`). The disclosure must describe what the *submitted build* actually contains (AI image generation for the Alex art, AI coding assistance, MobileSAM if the shipped art derives from it) — not the paused asset pipeline. Five-minute job, but only correct if done *after* the build freezes. |
| (f) Individual registration form | **OPEN CHECK — do not assume** | Jam materials (per pack §3/§4F) state a separate individual registration form is required and an itch-only submission may be disqualified. Ryan confirmed joining the jam on itch; the separate form has never been confirmed either way. This is the cheapest potentially-fatal item on the list: verify first. |

**Hard blockers to submitting at all:** the itch upload + jam submission itself (a), and *potentially* the registration form (f). **Hard blockers to development-funding consideration:** GDD (b) and video (c). The game binary is *not* a blocker.

---

## 7. Finish plan — Nov 9 → Nov 14 (≈2 focused hours/day ≈ 10 hours total)

### MUST (submission fails or funding consideration is forfeited without these)

1. **Verify the registration form** — browser check against the jam's requirements; complete it if outstanding. *~15–30 min. Do first; it gates everything else's value.*
2. **One full human playtest in a browser** — both runs, all the way to Comparison, from the release build (not the IDE). Note any blocker + time both runs (replaces this audit's duration estimate with a measurement). *~30 min including notes.*
3. **Assemble the standalone GDD (6–8 pp, PDF)** from v2 + pack outline + economy proposal, applying the v2 §7 edits: single learning outcome, Month Timeline as worked example, systems→FinLit table (rewrite from v1's table — several v1 rows describe cut systems), classroom/new-months roadmap, honest accessibility + localisation positions, realism sources. *~2.5–3 h — the largest single item; start Nov 10 morning.*
4. **Record and edit the 2-minute video** on the v2 storyboard: hook (rent due, empty jar) → Run 1 bike on card → interest + minimum eating Paycheck 3 → Run 2 same shock absorbed by the jar → comparison screen. Actual gameplay capture (VHS-style scripted capture or screen record), captions burned in. *~2–2.5 h.*
5. **Itch project page + upload + jam submission** — upload the Nov 9 (or later) web build, write the page (1-sentence pitch, how FinLit is taught through play, "rates are simplified for play" note, credits), embed playable-in-browser, test from a clean browser profile, then submit to the jam (not just publish). *~1.5 h.*
6. **Finalise the AI disclosure** against the frozen build (see §6e) and paste the budget into its submission form (pack §4D with v2 wording touch-ups). *~30 min combined.*

### SHOULD (highest rubric return per hour)

7. **Render the Month Timeline in the Reveal** — the model already records every event string per run (`RunSummary.timeline` is populated and unmodifiable-packaged); this is UI-only work in `main.dart` `_reveal()` plus, ideally, one contrast row ("Shocks on the card cost $X + $Y interest; from the jar they would have cost $X"). This is the single change that moves Educational Impact toward Strong and gives the GDD/video their worked-example artefact. *~1.5–2 h including a widget test.*
8. **Fix the two transparency nits** — (a) Night Out / Phone buttons state "…from Week Cash — anything short goes on the card" (one string each); (b) decide and document the over-limit rule (simplest honest fix: one line in the footer/GDD — "interest and essentials can push the card past its $500 limit; new charges can't"). *~30 min.*
9. **Submission hygiene** — replace `game/README.md` boilerplate, set web `<title>`/meta description to the game's. *~15 min.*

### COULD (only if the above lands early)

10. Split-stepper QoL if the playtest shows tedium (e.g. a neutral "put the rest in Week Cash" convenience that allocates without recommending a *split* — needs care to stay inside the no-suggested-split rule).
11. Explicit `Semantics` labels on the RoomScene containers + a keyboard tab-through check, to firm up the accessibility bonus claim.
12. Push the final game + this review + GDD sources to `Mocker/make-the-rent` (repo currently mirrors the Oct 24 state).

**Suggested sequencing:** Nov 10 — items 1, 2, start 3. Nov 11 — finish 3, item 7 if GDD finishes early. Nov 12 — item 4, items 8–9. Nov 13 — items 5, 6, clean-profile verification. **Nov 14 — submit (target), leaving Nov 15 as pure buffer**, per the standing plan.

---

## Verdict

The game itself is *done* in the sense jam games rarely are: a complete, deterministic, test-covered loop whose teaching mechanic is the game's structure rather than its text. Against the rubric, the build already earns its Prototype and FinLit Integration points. What stands between this and a competitive submission is almost entirely **packaging**: no standalone GDD, no video, an unverified itch submission path, one unconfirmed registration form, and one UI screen (the Reveal) that doesn't yet show the artefact the whole design was built around. All of it fits the Nov 9→14 window at two focused hours a day — if the GDD and video start first and the game code is touched only for item 7/8.
