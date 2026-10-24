# Gate 2 — Proposed mask → part mapping (awaiting Ryan's approval)

SAM run: gateway `sam_segment_auto` on `alex_paperdoll.webp` (laptop: `G:\Dev\10_Projects\pc-automations\zoud\`), Oct 23, 2026 — **65 masks**, job `138b66bbdd13`, masks at `sam-headless-mcp\jobs\138b66bbdd13\masks.npz`, overlay fetched to `masks_overlay_paperdoll.png` in this folder.
**Do NOT run `sam_assemble_layers` until Ryan approves/corrects this mapping** (rig2d SKILL Gate 2).

Canvas 1920×1280. Mask indices from the overlay / segment output.

## Proposed parts (for sam_assemble_layers)

| Part | Masks | Notes |
|---|---|---|
| hair | 8 + 56 + 60 + 64 | Top mass (8) + side/back bits |
| face | 5 | Baked face; eyes as separate layers below |
| eye_r | 58 | Viewer's left eye on the doll |
| eye_l | 59 | Viewer's right eye — naming flips at assembly to character space |
| ear_r / ear_l | 55 / 57 | Optional — can merge into hair; proposed separate (cheap) |
| neck | 52 | |
| torso | 1 | Largest torso union (apron + shirt + pocket 19 + straps all inside it). Overlapping sub-masks 3, 4, 26, 33–35, 37, 51 discarded as duplicates |
| upper_arm_A (viewer-left) | 14 + 25 + 38 | Sleeve cap + arm segment |
| forearm_A | 23 | (9 is the forearm+hand union — alternative single-piece option) |
| hand_A | 27 | |
| upper_arm_B (viewer-right) | 11 (= 22 + 36) | Sleeve cap 22 + skin 36 |
| forearm_B | 24 | (10 is forearm+hand union — alternative) |
| hand_B | 28 | |
| leg_L | 6 (= 17 + 12) | Whole-leg union; knee split exists (17 upper / 12 lower) if ever needed — legs don't bend in this game |
| leg_R | 7 (= 18 + 13) | |
| shoe_L | 21 | Side-profile shoes (doll art quirk) — assembled at leg bottoms |
| shoe_R | 20 | |
| face variants | mini-head faces: calm 41, closed 42, surprised 43, smile 40 | From the 4 mini heads (masks 29–32 + hair 44–47). Face-kit sheet material for blink/surprise swaps |

## Discard
- 0 — background (full-canvas)
- 3, 4, 9, 10, 15, 16, 19, 26, 33–35, 37, 51, 53, 54 — sub-masks/duplicates contained in the unions above (53/54 are the leg-top openings, inside 6/7)

## Open questions for Ryan at this gate
1. Forearms: separate hand layers (proposed) vs single forearm+hand pieces (masks 9/10)? Separate hands serve `payday_split` better; single pieces are simpler.
2. Ears as own layers vs merged into hair? Proposed separate, zero cost either way.
3. Shoes are side-profile in the doll while everything else is front — acceptable stylistically, or regenerate shoes front-view later?
