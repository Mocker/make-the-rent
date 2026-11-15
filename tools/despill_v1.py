"""Despill v2 (Oct 23 recipe) for the V1 Alex layers.

Hard kill: alpha -> 0 where G > 150 AND G - max(R,B) > 90 (near-pure chroma).
Soft band: G > 170 AND 60 <= G - max(R,B) <= 90 -> clamp G to max(R,B).
The apron's green sits at diff ~56, below both bands, so it survives.
"""
import json, os, shutil
import numpy as np
from PIL import Image

SRC = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA_v1/alex_layers_raw"
OUT = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA_v1/alex_layers_despilled"
DOLL = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA_v1/doll_v1_fixed.png"
os.makedirs(OUT + "/layers", exist_ok=True)

pivots = json.load(open(SRC + "/pivots.json"))
order = pivots["order"]

total_killed = 0
for name in order:
    img = np.array(Image.open(f"{SRC}/layers/{name}.png").convert("RGBA")).astype(np.int32)
    r, g, b, a = img[..., 0], img[..., 1], img[..., 2], img[..., 3]
    diff = g - np.maximum(r, b)
    kill = (a > 0) & (g > 150) & (diff > 90)
    soft = (a > 0) & ~kill & (g > 170) & (diff >= 60) & (diff <= 90)
    total_killed += int(kill.sum())
    img[..., 3] = np.where(kill, 0, a)
    img[..., 1] = np.where(soft, np.maximum(r, b), g)
    Image.fromarray(img.astype(np.uint8), "RGBA").save(f"{OUT}/layers/{name}.png")
    print(f"{name}: killed {int(kill.sum())}, soft-despilled {int(soft.sum())}")
print("total alpha-killed px:", total_killed)
shutil.copy(SRC + "/pivots.json", OUT + "/pivots.json")

# ---- verification ----
def composite(base_dir, order):
    canvas = Image.new("RGBA", (1920, 1280), (0, 0, 0, 0))
    for name in order:
        canvas.alpha_composite(Image.open(f"{base_dir}/layers/{name}.png").convert("RGBA"))
    return canvas

comp = composite(OUT, order)
comp.save(OUT + "/composite_preview.png")
doll = Image.open(DOLL).convert("RGBA")
ca, da = np.array(comp).astype(np.int32), np.array(doll).astype(np.int32)
both = (ca[..., 3] > 30) & (da[..., 3] > 30)
delta = np.abs(ca[..., :3] - da[..., :3]).max(axis=2)
print("composite vs doll: px opaque in both:", int(both.sum()),
      "| px with RGB delta>12 in overlap:", int((both & (delta > 12)).sum()))
comp_only = (ca[..., 3] > 30) & (da[..., 3] <= 30)
print("composite px where doll is transparent (should be ~0):", int(comp_only.sum()))

torso = np.array(Image.open(f"{OUT}/layers/torso.png").convert("RGBA")).astype(np.int32)
op = torso[..., 3] > 200
green_apron = op & (torso[..., 1] > torso[..., 0] + 20) & (torso[..., 1] > torso[..., 2] + 20)
print("apron-region px:", int(green_apron.sum()),
      "mean RGB:", [round(float(torso[..., i][green_apron].mean()), 1) for i in range(3)])

# green halo check on dark background
dark = Image.new("RGBA", (1920, 1280), (24, 24, 28, 255))
dark.alpha_composite(comp)
dark.convert("RGB").save(OUT + "/composite_dark.png")
darr = np.array(comp).astype(np.int32)
halo = (darr[..., 3] > 0) & (darr[..., 1] - np.maximum(darr[..., 0], darr[..., 2]) > 40)
print("residual strong-green-excess px in composite (apron is ~56 diff, halo would be >90):",
      int(((darr[..., 3] > 0) & (darr[..., 1] - np.maximum(darr[..., 0], darr[..., 2]) > 90)).sum()),
      "| px with diff>40:", int(halo.sum()))
print("despilled set written:", OUT)
