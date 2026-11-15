# rent_due

Flutter web app for **RENT DUE! — One Month, Run It Back**, a deterministic financial-literacy game for the Zoud GameLab jam.

For overall project context, design specs, and asset status, see the [root README](../README.md) and `../docs/` (`NARROWED_DESIGN_V2.md`, `REALISTIC_ECONOMY_PROPOSAL.md`, `GAME_REVIEW_2026-11-09.md`).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.13.5` per `pubspec.yaml`)
- Chrome (for local web runs)

## Commands

Run from `game/`:

```sh
# Install dependencies
flutter pub get

# Run locally in Chrome
flutter run -d chrome

# Run all tests (16 model tests + 2 widget tests)
flutter test

# Run static analysis
flutter analyze

# Build release web bundle (outputs to build/web/)
flutter build web --release
```

## Project Structure

- `lib/game_model.dart` — Pure Dart economy and state machine (`GameModel`, no Flutter imports). Deterministic across runs: 4 weekly paychecks (`$455`, `$470`, `$380`, `$460`), `$900` rent, `$160`/wk essentials, `$500` credit card limit (`$12` interest per full `$100` owed in Weeks 3–4, `$25` minimum payment), weekly events/shocks, the `Buffer Jar → Week Cash` Shortfall Cascade (card excluded), and `Ending` (`nothingOwed`, `onTheCard`, `rentShort`).
- `lib/main.dart` — Flutter Material 3 UI (`RentDueApp`, `GameScreen`) driving the `Phase` flow (`title`, `split`, `room`, `dilemma`, `shock`, `cascade`, `ending`, `reveal`, `comparison`, `practiceEnd`), including Week 1 practice mode and Run 1 vs. Run 2 ("Run It Back") comparison.
- `test/game_model_test.dart` — 16 unit and full-playthrough tests verifying interest/minimum-payment math, split/essentials overflow, shocks, cascade ordering, determinism, and all three endings.
- `test/widget_test.dart` — Widget test verifying the title screen and both entry points (`Play — Run 1`, `Practice Week 1`).
- `assets/` — Runtime assets declared in `pubspec.yaml` (`alex.png`).
- `web/` — Flutter web host files (`index.html`, `manifest.json`, icons).
