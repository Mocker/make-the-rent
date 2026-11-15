# Gate 2 — Proposed mask → part mapping, V1 doll (awaiting Ryan's approval)

SAM run: gateway `sam_segment_auto` on `doll_v1_fixed.png` (laptop: `G:\Dev\10_Projects\pc-automations\zoud\alex_paperdoll_v1.png`), Oct 24, 2026 — **61 masks**, job `6d35a9a0e9ae`, masks at `sam-headless-mcp\jobs\6d35a9a0e9ae\masks.npz` (fetched copy: `masks_v1.npz` in this folder), overlay fetched to `masks_overlay_v1.png` in this folder.
**Do NOT run `sam_assemble_layers` until Ryan approves/corrects this mapping** (rig2d SKILL Gate 2).

Canvas 1920×1280. Mask indices from the overlay / segment output. Every one of the 61 masks is identified below (visual overlay check + per-mask colour sampling + containment tests against the union masks).

## Pre-SAM paint-out fixes (Gate 1, approved by Ryan)

Applied to a copy of the doll → `doll_v1_fixed.png` (original untouched). Chroma sampled from the image background: RGB (26, 248, 34). 19,315 px changed, **0 px outside the six target windows**:

- Torso hip knobs (discs fitted at (169, 833) and (446, 833), r≈30): painted to chroma outside the torso silhouette; the corner inside the silhouette was restored to flat apron (55, 134, 83) along the extrapolated edge/hem lines, so the torso keeps a clean corner. The two strap-top knobs were **kept** (verified still apron fill).
- Leg ankle balls: painted to chroma — 0 skin pixels remain in either ankle window.
- Leg top domes: only the part protruding above the jeans tip line was painted (leg L line y=420, leg R y=505); the flush skin cap below the line stays and will sit under the torso in assembly — 0 skin pixels remain above either line.

## Proposed parts (for sam_assemble_layers)

Pivot conventions mirror the Oct 23 assemble (`args_assemble.json`): limbs `bbox_top_center` (pivot at the joint that attaches to the parent), head-group parts `bbox_bottom_center`, eyes `centroid`, torso `bbox_bottom_center`.

| Part | Masks | Pivot | Group | Notes |
|---|---|---|---|---|
| hair | **derived** (see below) | bbox_bottom_center | head | SAM returned no hair-only mask — only the head union (2). Derived = 2 AND NOT 15: single clean component, 85,480 px |
| face | 15 | bbox_bottom_center | head | Baked face incl. ears (no separate ear masks this run — ears ride with face/hair) |
| eye_r | 57 | centroid | head | Viewer's left eye — naming flips to character space at assembly |
| eye_l | 58 | centroid | head | Viewer's right eye |
| neck | 36 | bbox_top_center | — | The neck-cup piece (rim mask 50 is 100% inside 36, discarded) |
| torso | 1 | bbox_bottom_center | — | Whole torso union: apron + shirt + straps + **kept** strap knobs all inside it. Sub-masks 6, 20, 28, 39–41, 43, 45, 46, 55 discarded as contained duplicates |
| apron_pocket | 26 | bbox_top_center | — | The separate pocket piece — **proposed as its own layer** (decision 2 below) |
| upper_arm_A | 16 | bbox_top_center | — | Whole piece (sleeve 30, skin 27, balls 49/44 all contained in it) |
| forearm_A | 25 | bbox_top_center | — | Caps 48/52 contained in it |
| hand_A | 24 | bbox_top_center | — | Wrist ball included in the mask |
| upper_arm_B | 17 | bbox_top_center | — | Whole piece (sleeve 31, skin 29, balls 51/42 contained) |
| forearm_B | 23 | bbox_top_center | — | Caps 47/54 contained |
| hand_B | 21 | bbox_top_center | — | Wrist ball 53 contained |
| leg_L | 8 + 56 | bbox_top_center | — | 56 is the leg-top skin cap strip (92% overlaps 8; union adds the full cap) |
| leg_R | 10 | bbox_top_center | — | SAM kept this leg's trimmed cap inside the leg mask — no separate cap mask exists |
| shoe_L | 18 | bbox_top_center | — | Viewer-left shoe, front view ✓ (toe sub-mask 37 is 100% inside 18) |
| shoe_R | 19 | bbox_top_center | — | Viewer-right shoe, front view ✓ (toe sub-mask 38 inside 19) |

**Z-order (back → front):** leg_L, leg_R, shoe_L, shoe_R, torso, apron_pocket, neck, face, hair, upper_arm_A, forearm_A, hand_A, upper_arm_B, forearm_B, hand_B, eye_r, eye_l.

## Decisions for Ryan (recommendations stated; all reversible at assembly)

1. **Fringe hair piece (mask 22) — recommend DROP from the rig layers.** The main head's hair is already complete (the derived hair mask is the full hair silhouette). The fringe is a near-duplicate of the head's own front swoosh from a separate generation pass; laid over the baked hair it risks a visible double hairline for zero coverage gain. The piece stays in the source art — if a future pass wants a swappable front-hair layer, it can be added as an overlay parented to face then.
2. **Apron pocket (mask 26) — recommend KEEP as a separate layer** (in the table above). Oct 23's pocket was drawn onto the apron, so merging was the only option; this doll's pocket is a discrete piece. Separate costs nothing at assembly (it parents to the torso) and buys a storytelling beat later — e.g. the pocket can bounce or hold the coin in `payday_split`. If you'd rather keep the layer count down, merging is a one-line change (add 26 to torso's mask list).
3. **The 4 mini heads — EXCLUDED from layers**, same as Oct 23. Whole heads 12 (calm), 13 (closed), 14 (surprised), 11 (smile); their face masks 33, 35, 34, 32; plus 59/60 (the surprised head's eye whites). All reserved as face-kit material for blink/expression work after the rig exists.
4. **Neck cup (mask 36) — recommend INCLUDE as the neck layer.** In the assembled bind pose the head group tilts on its bottom-center pivot (`breath`/`tilt`); without a neck bridge, tilts open a gap at the throat between head and torso. The cup is one clean mask and sits hidden behind the chin/apron collar in bind. (Oct 23's assemble carried a neck layer the same way.)
5. **Hair via derived mask — recommend approving one local pre-assembly step:** append mask 61 = (2 AND NOT 15) to a copy of the npz, so the hair layer contains zero skin pixels. Fallback if you'd rather not derive: hair = mask 2 with the face layer drawn over it — the composite looks identical, but the hair PNG then carries hidden skin pixels (dirtier for hole detection later).

## Discard

- 0 — background (full-canvas)
- 3 — disjoint union of upper_arm_B (17) + leg_R (10); both covered separately
- 4, 5 — unions of mini heads 1+2(+3 sliver); heads proposed individually as face-kit
- 7 — disjoint union of shoe_L (18) + smile mini head (11)
- 9 — disjoint union of both hands (21 + 24)
- 6, 20, 28, 39, 40, 41, 43, 45, 46, 55 — torso sub-masks (apron front, shirt halves, straps, kept knobs), 97–100% contained in torso (1)
- 27, 29, 30, 31 — arm sub-masks (sleeves / skin sections), contained in 16/17
- 37, 38 — shoe toe sub-masks, 100% contained in 18/19
- 42, 44, 47, 48, 49, 51, 52, 53, 54 — arm joint-ball sub-masks, 94–100% contained in their whole-piece masks (16/17/23/25/21)
- 50 — neck-cup rim, 100% contained in 36

## Open questions for Ryan at this gate

1. Fringe: drop (recommended) or keep as a front-hair overlay?
2. Pocket: separate layer (recommended) or merged into torso?
3. Neck: include (recommended) or drop?
4. Hair: derived mask 61 (recommended) or mask-2-with-face-overdraw?
