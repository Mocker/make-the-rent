# RENT DUE! — One Month, Run It Back

A financial-literacy game for the **Zoud GameLab** jam (submit target Nov 14, 2026).
Alex, 23, café barista in Eugene, gets paid four times in one month. Split each
paycheck into the Rent Tin, the Buffer Jar, and Week Cash; absorb or charge the
shocks; make rent. Then **Run It Back**: the same month again, knowing what's
coming, and compare.

The economy is a realistic scenario, not an arcade one: take-home paychecks
$455/$470/$380/$460 at Oregon's $15.55 minimum wage plus tips, $900 rent on a
below-market studio, $160/week of itemized essentials — and rent can't go on
the credit card, because the landlord takes bank transfer only.

## Layout

- `game/` — the Flutter web game (pure-Dart model in `lib/game_model.dart`,
  UI in `lib/main.dart`, economy + playthrough tests in `test/`).
  Run: `flutter test` / `flutter build web`.
- `docs/` — `NARROWED_DESIGN_V2.md` is the design authority;
  `REALISTIC_ECONOMY_PROPOSAL.md` records the approved numbers and the
  card-out-of-cascade addendum; `CONCEPT_AND_SUBMISSION_PACK.md` is the
  submission pack.
- `assets/props/` — Blender renders of the six props (Buffer Jar, Rent Tin,
  Credit Card, Fridge, Bike, Phone) + their build scripts.
- `assets/character/` — Alex: `stageA/` holds the approved paper-doll art and
  the despilled SAM layer set; `rig_alex/` is the finished rig2d rig
  (18 layers, FK parents, painted-lid blink, hole pass verified —
  `inpaint_jobs/jobs.json` is the record).
- `tools/` — gateway client and rig/blink build scripts used to produce the
  character assets.

## State — Nov 15, 2026 (sync)

This repo is the current source of truth for RENT DUE! as of Nov 15, 2026.

- `game/` — Flutter web game, unchanged since Oct 24; passed the Nov 9 review (17/17 tests, release build). See `docs/GAME_REVIEW_2026-11-09.md`.
- `docs/RENT_DUE_GDD_Draft_2026-11-14.md` — the GDD draft for the jam's development-funding consideration (shipped numbers throughout; §5 describes the shipped Reveal).
- `assets/character/concepts/` — the locked V1 flat-vector art direction (Alex, props sheet, game-screen mock, expressions).
- `assets/character/stageA_v1/` — Gate 1/2-approved V1 paper doll: source dolls, fixed doll (paint-outs applied), SAM masks (incl. derived hair mask 61), mask overlay, Gate 2 mapping, and the canonical despilled layer set. (Pre-despill raw layers excluded as regenerable intermediates.)
- `assets/character/rig_alex_v1/` — the built V1 rig: 17 layers, blink painted, hole pass complete, bind containment verified locally. NOT yet wired into the game, and gateway `rig2d_validate` is still owed (laptop was asleep at build time). Inpaint job working files excluded; `jobs.json` records kept.
- `tools/` — gateway client plus the v1 build/blink/despill scripts used to produce the above.
