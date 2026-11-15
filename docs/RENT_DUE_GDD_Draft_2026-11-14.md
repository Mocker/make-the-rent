# RENT DUE! — One Month, Run It Back — Game Design Document (DRAFT)

**Status:** DRAFT prepared 2026-11-14 (Sat) for Ryan's review — not submitted, not final.
**Jam:** Zoud GameLab FinLit jam, theme "Make FinLit Fun" — https://itch.io/jam/zoud-gamelab
**Deadline:** Sun Nov 15, 2026, 11:59 PM anywhere-on-earth (itch may show Nov 16). No late entries.
**Game:** Flutter web, playable in browser on itch. No download, no signup, no account.
**Build verified:** 2026-11-09 — `flutter analyze` clean, 17/17 tests pass, fresh release web build
(`game/build/web/main.dart.js`, 2.1 MB). See `GAME_REVIEW_2026-11-09.md`.

**Sources for every number below (no invented figures):**
- Design authority: `NARROWED_DESIGN_V2.md` (adopted Oct 23, 2026), as amended by
  `REALISTIC_ECONOMY_PROPOSAL.md` (approved Oct 23, 2026, incl. card-out-of-cascade addendum).
- Shipped-build evidence: `GAME_REVIEW_2026-11-09.md` — audited `game/lib/game_model.dart`
  (351 lines), `game/lib/main.dart` (882 lines), `game/test/` (2 files).
- Pack outline, budget and disclosure skeleton: `CONCEPT_AND_SUBMISSION_PACK.md` §4–§5
  (v1 §1–§2 superseded by v2; budget reworded per v2 §7).

**Open items before this GDD can ship (do not delete this box until each is closed):**
1. [ ] Screenshots — insert real gameplay captures (title, split, room, shock, cascade, ending,
   comparison). Placeholders marked `[SCREENSHOT: …]` below.
2. [ ] The Reveal gap — see §5. The shipped Reveal shows four aggregate rows only; the
   per-moment Month Timeline the design promises is built in the model but not rendered in
   the UI. Either implement the timeline render or edit §5 to describe the shipped Reveal.
3. [ ] AI disclosure (§10) — finalise against exactly what was used in the final build; delete
   any tool not actually used.
4. [ ] Registration — confirm the separate Google registration form was actually submitted
   (link verified live Nov 14; itch join alone is not the same step, and the FAQ warns an
   itch submission without it "may be disqualified").
5. [ ] Itch upload + submit — upload the Nov 9 release build, submit to the jam, verify
   playable from a clean browser profile.

---

## 1. Pitch

**RENT DUE! — One Month, Run It Back.** Alex, 23, is a café barista on variable shifts
in a below-market older studio a few blocks from the café. Rent is $900, due after the
fourth paycheck. One month, four paychecks, about five minutes a run — and the same
month, played twice, so the player can see what a buffer actually does.

**One user, one frustration:** *"I get paid and feel fine. Then one thing goes wrong,
it goes on the card, and rent week is panic — every single month."*

**One learning outcome** (the whole game exists to teach this one sentence, by experience):

> A small buffer, built on payday before spending starts, turns a $200 shock from a
> debt spiral into an inconvenience — even when your pay changes week to week.

**Target audience:** first-time renters on variable/entry-level pay — and, as a funded
follow-on, classrooms: one complete month plus a replay fits a single lesson period
(see §8).

## 2. Core loop — three verbs, one month

The month is **deterministic**: same pay, same shocks, same order, every run.
No randomness anywhere in `lib/` (verified by grep in the Nov 9 review).

### Verb 1 — SPLIT (every payday)
The paycheck lands as cash. The player allocates **every dollar** into three containers:
- **Rent Tin** — locked until rent day; money in cannot be spent.
- **Buffer Jar** — the hero prop; accessible only when a shock hits.
- **Week Cash** — everything else: food, fun, regular bills (auto-leave from Week Cash).

The confirm button stays disabled until the split sums to the full net paycheck.
There is **no "correct split" shown, ever** — no percentages, no recommended allocation,
no green checkmarks. Run It Back is how the player finds their split.

### Verb 2 — CHOOSE (one dilemma per week, consequences landing 1–2 weeks later)

| Week | Dilemma | Options (all defensible) |
|---|---|---|
| 1 | Friends' night out | Go $60 / Go cheaper $25 (say so out loud) / Skip $0 |
| 2 | **Shock: bike breaks, $180** — Alex's transport to work | Fix from Buffer Jar / Fix from Week Cash / Put it on the card / Don't fix, take the bus ($30 pass now + $45 late fee in Week 4) |
| 3 | **Short paycheck: shifts cut** — $380 vs $470 the week before | Not a choice; this is the test the month was built around. Side gig available: +$80 pay, −$30 costs, net +$50 |
| 4 | **Shock: phone screen cracks, $90**, rent in 3 days | Fix from Week Cash / Put it on the card / Live with the crack (free; the phone stays cracked on the end screen — a kept receipt of a good decision) |

### Verb 3 — ABSORB or CHARGE (only when a shock hits)
Two big buttons: **Pay from Buffer** (jar drains, done) or **Put It On The Card**
(fast now). If rent day arrives with the Tin short, the **Shortfall Cascade** runs
in the open, one step per button press, player confirming each step: Rent Tin →
Buffer Jar → Week Cash → Rent Short. **Rent is paid by bank transfer — the card
never covers rent.** The card still absorbs shocks and essentials overflow, but
money sitting on the card can't pay the landlord, so where the money sits matters.

### Run It Back
1. **Run 1 — Blind.** Play the month. Most players put the Week 2 shock on the card,
   meet the Week 3 short paycheck with no cushion, and scrape or miss rent. The game
   never says what they should have done.
2. **The Reveal.** One screen, numbers only (see §5).
3. **Run 2 — Same month, on purpose.** The prominent button is
   *"Run It Back — same month, your call."* Same pay, same shocks. The player now
   splits their first paycheck differently *because they know what's coming* — which
   is exactly what a real buffer is for in a life where shocks are not random, only
   unscheduled.
4. **Comparison, not a grade.** Run 1 vs Run 2 side by side: rent paid?, card
   balance, buffer left, plus interest paid. One prompt — *"What did you change?"* —
   with three tappable self-descriptions: *"I fed the jar first" / "I skipped a want" /
   "I still used the card — but less."* Their words, not the game's lesson.
   Response: *"Noted. It's your month."*

**Practice mode (judge path):** Week 1 as a no-fail practice payday, one tap from the
title screen. No signup, no tutorial wall. A judge who only does Run 1 still gets a
complete game with an ending in ~5 minutes; both runs ≈ 11 minutes.

[SCREENSHOT: title screen — "RENT DUE! / One Month, Run It Back", Rent $900 line, Practice Week 1 button]
[SCREENSHOT: split screen — paycheck, three containers, itemised essentials]

## 3. The economy — realistic numbers, all in the open

Grounding (checked Oct 23, 2026): Oregon minimum wage $15.55/hr (Lane County/Eugene),
no tip credit; barista ≈ $15.55–16.50/hr + ~$1–2/hr tips, ~29 hrs/wk → ≈ $2,150/mo
gross → ≈ $1,730–1,780/mo take-home. Eugene studio average $1,190–1,430 — a solo
barista at market average cannot carry a place alone. Alex's $900 studio is
below-market on purpose; the burden itself is the lesson. All rates are
**simplified for play** and labelled as such in-game and here — not financial advice.

| Item | Amount |
|---|---|
| Paychecks (take-home, net) | Week 1 $455 / Week 2 $470 / Week 3 $380 (short — shifts cut, $90 under Week 2) / Week 4 $460. **Total $1,765** |
| Rent | $900, due after Paycheck 4 |
| Essentials | $160/week ($640/month), itemised in the UI: groceries $75, utilities $42, phone $13, bus pass $12, laundry & toiletries $18. If Week Cash is short, the rest goes on the card (exact overflow amount shown) |
| Card | $500 limit. Interest: flat **$12 per full $100 owed**, applied at the start of Weeks 3 and 4, only if a balance exists, interest before minimum. Minimum payment: **$25 or the full balance if less**, auto-deducted from Paychecks 3 and 4 |
| Buffer Jar | Earns **nothing**. Deliberate: a first buffer's job is absorption, not growth |
| Night out (W1) | $60 / $25 / $0 |
| Bike shock (W2) | $180; bus option $30 pass now + $45 late fee in Week 4 |
| Side gig (W3) | +$80 pay, −$30 costs, net +$50 (disclosed before the choice) |
| Phone shock (W4) | $90 |

**Monthly math — the whole game in one line:** income $1,765 − rent $900 − essentials
$640 = **$225 total slack. Both shocks together are $270 — more than the month's
entire slack.** That single fact is the game.

**Traced lines (proven by deterministic playthrough tests, 17/17 passing):**
- **Careful** (jar built to $180 by Week 2, cheap night out, gig taken, phone lived-with
  or absorbed): bike absorbed by the jar; Week 3's short paycheck pushes ~$25 of
  essentials onto the card, cleared by the Week 4 minimum payment. Ends rent paid,
  card $0, buffer $20 → **Rent Paid, Nothing Owed**. Tight the whole way, never hopeless.
- **Careless** (charge both shocks, full night out, thin tin splits): card $244 +
  $24 interest at rent day → **Rent Paid, On The Card**.
- **Cash-absorb** (absorb both shocks from cash): $795 of $900 accessible at rent day
  → **Rent Short**, reachable through plausible play. A maximum-spiral line also lands
  On The Card (card $902) because its money sat in the tin.

### Endings (3, all complete, none shaming)
- **Rent Paid, Nothing Owed** — rent paid, card balance $0. (Buffer left is shown as a
  number in the Reveal/Comparison, not gated — an empty jar after absorbing two shocks
  is the jar having done its job, not failure.)
- **Rent Paid, On The Card** — rent covered, but the end screen shows the minimum
  payment already waiting in *next* month.
- **Rent Short** — landlord note on the door. The cascade that fell short is shown
  exactly, and the primary button is Run It Back. Failure is a rehearsal invitation,
  not a verdict.

[SCREENSHOT: room screen — Rent Tin fill line vs $900 target, Buffer Jar level, card heat state]
[SCREENSHOT: ending screen + comparison table, Run 1 vs Run 2]

## 4. The room is the balance sheet

Single isometric room diorama; state swaps (not new models) show finance changing.
Six props, each with real state work:

| Prop | States | What it teaches |
|---|---|---|
| **Buffer Jar** (hero) | 5 fill levels + crack overlay after a shock-absorb | The thesis, in glass |
| **Rent Tin** | Fill line vs rent target line — always visible | The goal, never off-screen |
| **Card** (oversized, on table) | Cool / warm / hot-cracked (3 heating states tied to balance bands) | The cost of the alternative, ambient |
| **Fridge** | Full / low / empty | Needs made visible from Week Cash |
| **Bike** | Working / broken (Week 2 shock) / bus pass on table instead | The shock has a face |
| **Phone** | Normal / cracked (kept crack = badge of the Week 4 decision) | A receipt the player chose |

**Character (rig2d):** layered-PNG paper-doll rig (Alex), designed motions `idle`
(breath + blink), `payday_split` (hands follow the player's split), `shock_react`
(one flinch-and-look at the broken bike/card, used at both shocks and nowhere else).
*Honest status at Nov 9 review: art in the shipped build is placeholder by design and
the rig2d pipeline is paused; the systems behind the props (jar fill levels, card heat
bands) are implemented and scored, the pictures are not. Do not present placeholder
art as final in the video — capture the shipped build as it is.*

## 5. The Reveal — numbers only, no lecture

[OPEN ITEM — see header item 2. As shipped (Nov 9 review): the Reveal shows four
aggregate rows — shocks put on the card, interest added, their total, shocks paid
from the Buffer Jar. No adjectives, no lecture; the numbers-only discipline holds.
What is **not** shipped: the design's Month Timeline — the per-moment strip of where
money was when each shock hit — plus the side-by-side counterfactual ("this $180
shock cost you $180 + $24" next to "$180 from the jar"). The model **builds** a full
`timeline` list for every event and carries it into `RunSummary.timeline`; the UI
never renders it. Before submitting, either implement the timeline render or rewrite
this section to describe the shipped four-row Reveal. Do not claim the timeline in
the submission if it is not in the build.]

The intended worked example (whether rendered in-game or shown here as a figure):
the same $180 bike shock — Run 1: on the card, +$12 interest, $25 minimum eaten
from Paycheck 3; Run 2: absorbed from the jar, month survives. That contrast is also
the video's money shot (§7).

## 6. Systems → FinLit mapping (the evidence for the 25-pt integration criterion)

| Concept | Mechanic | Visible consequence | Takeaway learned by playing |
|---|---|---|---|
| Pay yourself first | Split every payday, before choices | Jar fills early = later events hurt less | Saving is a decision made at payday, not with "what's left" |
| Emergency fund | Shocks cost real money | With buffer: pay from jar, week continues. Without: forced onto card | A buffer converts a crisis into an inconvenience |
| High-interest debt | Card grows $12 per $100 per boundary; $25 minimum auto-deducted | Card prop heats; Paycheck 3 arrives already eaten | Debt interest outruns savings interest — pay the expensive money first |
| Needs vs wants | Night out $60/$25/$0; essentials itemised | Fridge empties when Week Cash is short; skipping a want leaves the tin fuller | Both can be valid — sequence and proportion matter |
| Recurring costs | Essentials $160/week, every week, itemised | Payday shrinks a little each week if cash is short | Small recurring costs are a budget line, not rounding error |
| Opportunity cost | You can rarely afford every good choice | Comparison shows what the other run kept | Every yes is a no to something else |
| Income volatility | Week 3 paycheck is $90 short, fixed and announced when it lands | A plan built on best-week income breaks | Budget to your typical week, not your best week |

## 7. Video (2 minutes, actual gameplay footage — still to capture)

Storyboard (from the pack; the contrast is now the game itself producing it):
- 0:00–0:15 — Hook: rent countdown, empty jar, "12 weeks" → **"4 paychecks. $900 rent.
  Don't max the card."** [Update the v1 line to the narrowed game.]
- 0:15–0:50 — A full week at speed: payday → pay-yourself-first → choices.
- 0:50–1:20 — The teaching moment, twice: the $180 shock in Run 1 (card, heats,
  eats Paycheck 3) vs Run 2 (jar absorbs it, month survives).
- 1:20–1:45 — Reveal + room visibly thriving, Week 4 rent paid.
- 1:45–2:00 — End card: title, "play in browser", what funded development adds next
  (new months, classroom pack).

Capture from the Nov 9 release build. No staged UI, no mock gameplay.

## 8. Development roadmap + funding ask — $42,000

Milestone-based development funding, 4 months part-time solo + contractors.
(Reworded per v2 §7: deliverables are new *months* on the proven loop, not "seasons".)

| Line | Amount | What it buys |
|---|---|---|
| Design + engineering (expansion) | $18,000 | New months on the proven loop (First Car, College), systems polish, platform builds |
| Art + animation | $7,000 | New rooms/props (Blender), 2nd character, added motions — finishing the placeholder art in §4 |
| Financial-literacy consultant review | $4,000 | Accuracy review of every card, rate, and Journal/Reveal line |
| Arabic localisation (professional, reviewed) | $5,000 | Full UI + Reveal translation, AED context, cultural review — never machine-only |
| Accessibility audit + remediation | $3,000 | External audit, screen-reader pass, cognitive-accessibility review |
| Audio (licensed/composed) | $2,000 | Music + SFX with captioned cues |
| QA + device testing | $2,000 | Browser/device matrix, classroom-hardware check |
| Pilot + outreach | $1,000 | School/youth-programme pilot materials and hosting — a 15-minute, two-run classroom activity |
| **Total** | **$42,000** | Milestones: M1 expanded vertical slice · M2 new months complete · M3 localisation + accessibility · M4 pilot release |

**Accessibility in the MVP (already shipped):** tap alternative to drag, captions for
all audio cues, no timed inputs, colourblind-safe meters (state by fill level and
icon, not colour alone), keyboard + touch. **Inclusivity bonus (up to +5):** achievable
in MVP. **UAE/Arab localisation bonus (up to +5):** *not* claimable from a currency
toggle alone — the rubric rewards authentic adaptation; the funded localisation line
above is the honest path, stated as a funded-development promise, not an MVP claim.

## 9. Team + tools

Solo entrant: Ryan Guthrie (senior software engineer / systems architect). Flutter
web build; rig2d procedural animation pipeline (author's own, deterministic renderer,
not generative); Blender isometric props; MobileSAM segmentation of character artwork
into rig layers. See §10 for the AI disclosure — finalise against the actual build.

## 10. AI disclosure (DRAFT — finalise against what was actually used)

> Generative and assistive AI tools were used in this submission and are disclosed
> as required: [AI coding assistant — code assistance and Blender Python prop
> scripts], [image generation — initial character artwork, subsequently segmented,
> cleaned and hand-assembled into animation layers], [MobileSAM — segmentation of
> character artwork into rig layers], [rig2d — author's own open procedural animation
> pipeline; deterministic renderer, not generative]. All gameplay design, financial
> content, balancing and final assets were authored/reviewed by the entrant, who
> holds/controls the rights to all submitted material.
>
> ⚠️ Delete any tool not actually used in the final build before submitting.
> Disclosure must match reality. AI use is disclosed on the submission form as
> required (judges-only view); the entrant retains IP and is responsible for
> rights/clearance on all assets, code and content.

## 11. Risks

- **FinLit accuracy:** numbers are simplified and labelled everywhere; the $4,000
  consultant line in the budget is the fix path.
- **Scope creep:** "one room, one character, one loop" is the rule. Any new idea goes
  to §8, not the build.
- **Art placeholder (§4):** the shipped build's art is placeholder by design; the
  $7,000 art line funds finishing it. The video must show the shipped build honestly.
- **Reveal timeline (§5):** implement the render or rewrite the claim before submitting.
- **Submission mechanics:** the separate registration form and the itch jam submission
  are two different steps — both required (see header item 4).

---

*Draft prepared 2026-11-14 from the sources listed at the top. Next step: Ryan reviews,
closes the five open items in the header box, exports to PDF, uploads with the game,
video and budget.*
