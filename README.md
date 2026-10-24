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
