# Zoud GameLab — Concept Scope + Submission Pack Outline

**Jam:** Zoud GameLab (Global Game Jam partner jam) — https://itch.io/jam/zoud-gamelab
**Theme:** Make FinLit Fun
**Deadline:** Sunday, Nov 15, 2026, 11:59 p.m. anywhere-on-earth (itch may show Nov 16)
**Prize pool:** Up to $140,000 USD in cash prizes + milestone-based development funding
**AI policy (verified Oct 21):** Generative AI allowed, must be disclosed on submission (judges-only view). Entrant retains IP and is responsible for rights/clearance on all assets, code and content.
**Status:** Scoped Oct 21, 2026 — not yet registered/committed. **Design narrowed Oct 23 (v2): see `NARROWED_DESIGN_V2.md` — its §1–§2 supersede §1–§2 below, and its §7 lists required edits to the pack sections below.**

---

## 1. Recommended concept (primary)

### RENT DUE! — Build Your Buffer

**One-liner:** A cozy 12-week apartment game where your room *is* your balance sheet. Get paid, make the week's money choices, survive the surprise bills — and build a $600 emergency buffer before rent is due.

**Player:** First-job / first-apartment, ages ~18–28. Secondary: classrooms and family play (simple language, no time pressure).

**Why this concept, for this rubric:**
- Financial Literacy Integration is 25 pts and rewards concepts *embedded in mechanics, not quizzes/text*. Here every core verb is a financial decision.
- Prototype & Gameplay is 25 pts: one room, one character, one week-loop — a complete, stable, judgeable prototype in a solo scope.
- Educational Impact is 15 pts: learning comes from consequences you can *see* in the room, plus a one-line end-of-week reflection.
- Creativity is 15 pts: the apartment visualising the balance sheet is the distinctive hook.
- Development Potential is 20 pts: the same loop expands cleanly into seasons (First Apartment → First Car → College), school pilots, and localisation — a credible funding story.

### Core loop (one week = ~90 seconds, 12 weeks = ~15–18 min run)

1. **Payday** — Income lands. Character does the rig2d `payday` motion (wave / celebrate).
2. **Pay yourself first (choice)** — Move any amount to Buffer Jar, or skip. Jar is a Blender prop that visibly fills.
3. **Three choice cards** — Each week presents 3 concrete choices (see systems below). Picking is the whole interaction: tap/click a card, character and room react immediately.
4. **Life happens (event card)** — One randomised event: car repair, hours cut, friend's birthday, found money, subscription renewal you forgot.
5. **Week settles** — Savings earn a little, debt charges a lot. Room state updates. One line appears in the Ledger Journal: what happened and why it mattered, in plain language.

**Win:** End Week 12 with rent covered **and** Buffer ≥ $600, with no card maxed.
**Lose (soft):** Rent short or a card maxes — game shows exactly which weeks caused it in the Journal and offers an instant retry. No shaming, no game-over screen lecture.
**Score:** Buffer size + debt avoided + Mood kept above zero. Replayability comes from different event decks and a “hard month” shuffle.

### The room is the balance sheet (Blender isometric props)

Single isometric room diorama. Use **one front angle per prop** for the room (the 8-angle turntable set is only needed if a prop goes into a shop/inventory view — do not pay that cost by default).

MVP prop list (10, bold simple shapes, flat colours — per the isometric-sprites skill rules):

| Prop | Financial meaning | States (swap sprite / tint, no new model) |
|---|---|---|
| Buffer Jar | Emergency savings | Empty / 1⁄3 / 2⁄3 / Full + glow |
| Fridge | Food / needs spending | Full / half / empty |
| Plant | Long-term growth / mood | Wilted / ok / thriving |
| Credit Card (on table, oversized) | Debt | Cool / warm / red-hot + cracks overlay |
| Piggy Bank | Small wins / spare change | Normal / full |
| Laptop | Income / work | Normal / “hours cut” dark screen |
| Sofa | Wants / comfort spending | Worn / upgraded (stretch) |
| Wall Calendar | Time to rent day | Week ticks fill in |
| Mail Pile | Bills / events | Small / growing |
| Lamp | Mood / energy in room | Dim / warm |

State swaps are the polish trick: judges *see* finance change without reading numbers.

### Character (rig2d)

Re-skin/re-layer the verified robot-demo pattern, not a new tech risk: layered PNGs, `head` group (eye_l, eye_r, mouth), body, arm_l, arm_r.

- **Parameters (character API):** `blink`, `breath`, `tilt_x`, `mouth_open`, `stress` (brows furrow / shoulders rise), `joy`
- **Motions (reusable clips):** `idle` (breath + blink, 48f), `payday` (wave + hop, 24f), `worried` (tilt + shake, on debt/event), `celebrate` (on Buffer milestone), `sleep` (week transition)
- **Art path:** Diffusion character → MobileSAM segmentation → merged layers + geometry pivots — the Oct 19 end-to-end path (viable, *not* push-button; semantic labelling is the known bottleneck, so budget one focused morning for it, or fall back to a procedural PIL/SVG character if labelling fights back).

### Systems → FinLit mapping (this table *is* the FinLit-integration evidence for judges)

| Concept | Mechanic | Visible consequence | Takeaway learned by playing |
|---|---|---|---|
| Pay yourself first | Step 2 every week, before choices | Jar fills early = later events hurt less | Saving is a decision made at payday, not with “what's left” |
| Needs vs wants | Choice cards are tagged only *after* you pick, in the Journal | Fridge empty hurts Mood; sofa upgrade doesn't help rent | Both can be valid — sequence and proportion matter |
| Emergency fund | Event cards cost real money | With Buffer: pay from Jar, week continues. Without: forced onto card | A buffer converts a crisis into an inconvenience |
| High-interest debt | Card balance grows at a deliberately painful weekly rate; savings grow slowly | Card prop heats up; minimum-payment trap card appears | Debt interest outruns savings interest — pay the expensive money first |
| Subscription creep | Small $9–$15 choices recur silently unless cancelled in a “Bills” moment | Mail pile grows; payday shrinks a little each week | Small recurring costs are a budget line, not rounding error |
| Opportunity cost / trade-offs | You can rarely afford all 3 good choices | Journal names what you traded away | Every yes is a no to something else |
| Income volatility | Two weeks have reduced/variable pay | A plan built on best-week income breaks | Budget to your typical week, not your best week |

Numbers stay round and legible ($20 / $50 / $150 events, $600 goal). Accuracy note for the GDD: rates are *illustrative and simplified*, labelled as such in-game and in the doc — not financial advice.

---

## 2. Scope — the cut line

### MVP (must ship by Nov 13 to be safe)
- Flutter **web** build playable in-browser on itch (no download friction for judges). Flutter target fits Ryan's platform preference and rig2d's shipped Flutter runtime (Rig2dBundle / Rig2dController / Rig2dWidget, 16 tests passing).
- 1 room, 1 character, 5 character motions, 10 props with state swaps
- 12-week loop, ~18 choice cards, ~10 event cards, Journal, win/lose + retry
- Buffer / Cash / Debt / Mood meters, simple-language mode ON by default
- Captions for all audio cues, colourblind-safe meter colours (shape + icon, not colour alone), keyboard + touch, no timed inputs

### Stretch (only if MVP is playable end-to-end)
- Sofa upgrade + second room corner, “Hard Month” reshuffle mode, AED currency toggle (see §5)

### Explicitly NOT in scope
- Multiplayer, accounts, backend, leaderboards, shop/IAP, 3D navigation, full Arabic translation, a second character, mesh-warp rig2d features

---

## 3. Build plan (energy-aware, collision-checked)

Known collision: **Meta Global AI Developer Hackathon build window Oct 26 – Nov 4** (submissions Nov 4). This plan therefore front-loads assets, pauses for Meta, and does the main build after.

| When | Work (mornings = heavy work) | Outcome |
|---|---|---|
| Oct 22–25 | Character art + SAM labelling (1 morning), Blender prop batch (10 props, single angle), rig.json + motions | All art locked before Meta |
| Oct 26 – Nov 4 | **Paused** (Meta hackathon). Optional 15-min card-text drafting only | No context-switch cost |
| Nov 5–9 | Core loop in Flutter: week state machine, cards, settling, Journal, room state swaps | Playable start-to-finish, ugly is fine |
| Nov 10–12 | Polish: motions timing, meters, accessibility pass, playtest + fix top 5 issues | Judge-ready build |
| Nov 13 | Submission pack: GDD, budget, video capture + edit | Pack complete |
| Nov 14 | Upload to itch, submit, verify playable from a clean browser | **Submitted a day early** |
| Nov 15 | Buffer day only — no planned work | Deadline insurance |

Registration (individual form — required, itch submission alone can be disqualified) should be done Oct 22–25, in the same sitting as joining the itch jam.

---

## 4. Submission pack outline (the other 75% of the work)

### A. Game
- [ ] Flutter web build, itch page set to playable in browser, controls + goal stated in first screen and on itch page
- [ ] Page includes: 1-sentence pitch, how FinLit is taught through play, credits incl. all free/AI assets, “rates are simplified for play” note

### B. Concept Doc / GDD (target 6–8 pages, PDF)
1. Pitch + target audience + why this audience's money moment matters
2. Learning outcomes (3, measurable: build a buffer, recognise interest asymmetry, spot recurring costs)
3. Core loop diagram + a worked example week (screenshots)
4. Systems → FinLit mapping table (§1 above, verbatim)
5. Content inventory: cards, events, balancing numbers (with “simplified/illustrative” note)
6. Art & tech: rig2d pipeline, Blender isometric pipeline, Flutter web — and why deterministic, git-diffable procedural animation suits a small team
7. Accessibility & inclusivity plan (MVP features + funded roadmap)
8. Audience / market: first-renter moment, schools & youth programmes, family play
9. Development roadmap + production plan (from the Budget, §D) — this section carries the 20-pt Development Potential criterion
10. Team + tools, incl. AI disclosure summary (§E)
11. Risks: financial accuracy (consultant review in budget), scope, platform

### C. 2-minute video (must be actual gameplay footage)
| Time | Beat |
|---|---|
| 0:00–0:15 | Hook: rent countdown, empty Jar, “12 weeks. $600 buffer. Don't max the card.” |
| 0:15–0:50 | A full week at speed: payday → pay-yourself-first → 3 choices |
| 0:50–1:20 | An event hits twice: once with a Buffer (minor), once without (card, interest, hot prop) — the teaching moment |
| 1:20–1:45 | Journal reflection + room visibly thriving, Week 12 rent paid |
| 1:45–2:00 | End card: title, “play in browser”, what funded development adds next (seasons, Arabic, schools pilot) |

### D. Game Budget — post-jam development funding ask (draft, for Ryan to adjust)
Framing: milestone-based development funding, 4 months part-time solo + contractors. **Total ask: $42,000**

| Line | Amount | What it buys |
|---|---|---|
| Design + engineering (expansion) | $18,000 | 2 new seasons (First Car, College), systems polish, platform builds |
| Art + animation | $7,000 | New rooms/props (Blender), 2nd character, added motions |
| Financial-literacy consultant review | $4,000 | Accuracy review of every card, rate, and Journal line |
| Arabic localisation (professional, reviewed) | $5,000 | Full UI + Journal translation, AED context, cultural review — never machine-only |
| Accessibility audit + remediation | $3,000 | External audit, screen-reader pass, cognitive-accessibility review |
| Audio (licensed/composed) | $2,000 | Music + SFX with captioned cues |
| QA + device testing | $2,000 | Browser/device matrix, classroom-hardware check |
| Pilot + outreach | $1,000 | School/youth-programme pilot materials and hosting |
| **Total** | **$42,000** | Milestones: M1 expanded vertical slice · M2 seasons complete · M3 localisation + accessibility · M4 pilot release |

### E. AI disclosure (draft wording — finalise with exactly what was used)
> Generative and assistive AI tools were used in this submission and are disclosed as required: [AI coding assistant — code assistance and Blender Python prop scripts], [image generation — initial character artwork, subsequently segmented, cleaned and hand-assembled into animation layers], [MobileSAM — segmentation of character artwork into rig layers], [rig2d — author's own open procedural animation pipeline; deterministic renderer, not generative]. All gameplay design, financial content, balancing and final assets were authored/reviewed by the entrant, who holds/controls the rights to all submitted material.
>
> ⚠️ Delete any tool not actually used in the final build before submitting. Disclosure must match reality.

### F. Submission checklist
- [ ] Individual registration form completed (separate from itch join)
- [ ] Joined jam on itch + game submitted to the jam (not just published)
- [ ] Game playable in browser, tested clean-profile
- [ ] GDD PDF, budget, and 2-min gameplay video uploaded/linked as required
- [ ] AI-use questions answered on submission form, matching §E
- [ ] All free/licensed assets credited, licences checked
- [ ] Age/eligibility: 18+ by Nov 15, 2026 ✓

---

## 5. Bonus-point strategy (honest version)

- **Inclusivity & Accessibility (up to +5):** Achievable in MVP — see §2 list. This is the realistic bonus.
- **UAE / Arab localisation (up to +5):** *Not* claimable from a currency toggle alone; the rubric rewards authentic adaptation (Arabic, AED, regional scenarios, culturally appropriate framing such as interest-free concepts where relevant). MVP move: include an AED display toggle + design the debt mechanic so an interest-free “community lending” variant is documented in the GDD roadmap, funded by the localisation line in the budget. Full points are a *funded-development* promise, not an MVP claim — say so plainly in the GDD.

## 6. Risks
- **SAM labelling bottleneck** (known): one-morning cap, procedural-character fallback ready.
- **Hackathon collision** (Meta Oct 26–Nov 4): plan already routes around it; if Meta slips, cut stretch items first, never the pack documents.
- **FinLit accuracy:** simplified numbers labelled everywhere; consultant line in budget shows judges the fix path.
- **Scope creep:** “one room, one character, one loop” is the rule. Any new idea goes to the GDD roadmap section, not the build.

## 7. Alternatives considered (not recommended)
- **Stock-market / investing game** — teaches a narrower, riskier lesson, invites misleading implications, harder to balance honestly.
- **Shop-tycoon / lemonade stand** — well-worn, business profit ≠ personal finance, weaker Fit for Zoud's wellbeing framing.
- **Quiz / trivia wrapper** — rubric explicitly scores this down: FinLit confined to text/quizzes instead of mechanics caps the 25-pt integration score.

---

*Prepared Oct 21, 2026. Next step if approved: registration + itch join + asset batch (Oct 22–25 plan above).*
