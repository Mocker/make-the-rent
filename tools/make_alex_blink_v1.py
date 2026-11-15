"""Paint closed lids into Alex's rig face layer, under the open-eye overlays.

Architecture (mirrors the rig2d face kit): the face layer carries the SHUT
state (skin + lash line painted inside each eye overlay's exact footprint);
the eye_r/eye_l overlay layers carry the OPEN state and are gated by the
`eyes_shut` param (scale -0.95 -> ~5% speck at 1). At bind the overlays
cover the painted lids exactly, so the bind composite is unchanged.
"""
import json, shutil
import numpy as np
from PIL import Image, ImageDraw

RIG = "/home/hatch/workspace/zoud-gamelab/assets/character/rig_alex_v1"
import os
_backup = f"{RIG}/layers/originals/face_baked_open.png"
if os.path.exists(_backup):
    shutil.copy(_backup, f"{RIG}/layers/face.png")  # idempotent re-runs
else:
    shutil.copy(f"{RIG}/layers/face.png", _backup)
face = Image.open(f"{RIG}/layers/face.png").convert("RGBA")
farr = np.array(face)

for eye_id in ("eye_r", "eye_l"):
    eye = np.array(Image.open(f"{RIG}/layers/{eye_id}.png").convert("RGBA"))
    foot = eye[..., 3] > 30
    ys, xs = np.where(foot)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    # skin tone: median of opaque face pixels in a ring just outside the eye
    ring = np.zeros_like(foot)
    ring[max(0, y0 - 26):y1 + 26, max(0, x0 - 26):x1 + 26] = True
    ring[y0:y1 + 1, x0:x1 + 1] = False
    skin_px = farr[ring & (farr[..., 3] > 200)][:, :3]
    skin = tuple(int(v) for v in np.median(skin_px, axis=0))
    # lash colour: darkest pixels of the eye art (its outline)
    eye_rgb = eye[..., :3][foot]
    lash = tuple(int(v) for v in eye_rgb[np.argsort(eye_rgb.sum(axis=1))[:200]].mean(axis=0))
    # paint the footprint with skin
    farr[foot] = (skin[0], skin[1], skin[2], 255)
    face = Image.fromarray(farr)
    # lash line: a gentle arc across the footprint at ~58% height
    d = ImageDraw.Draw(face)
    w, h = x1 - x0, y1 - y0
    pts = []
    for i in range(21):
        t = i / 20
        x = x0 + 5 + t * (w - 10)  # inset: keep the line inside the overlay footprint
        y = y0 + h * (0.58 - 0.10 * (1 - (2 * t - 1) ** 2))  # slight smile-curve
        pts.append((x, y))
    d.line(pts, fill=(lash[0], lash[1], lash[2], 255), width=6)
    farr = np.array(face)
    print(eye_id, "footprint", (x0, y0, x1, y1), "skin", skin, "lash", lash)

face.save(f"{RIG}/layers/face.png")

# rig.json: add eyes_shut param + gate bindings on the eye overlays
rig = json.load(open(f"{RIG}/rig.json"))
rig["parameters"]["eyes_shut"] = {"default": 0.0, "min": 0.0, "max": 1.0}
rig["bindings"] = [b for b in rig["bindings"] if b["param"] != "eyes_shut"]
for eye_id in ("eye_r", "eye_l"):
    rig["bindings"].append({"target": f"layer:{eye_id}", "param": "eyes_shut",
                            "op": "scale", "scale": -0.95})
json.dump(rig, open(f"{RIG}/rig.json", "w"), indent=1)
print("face painted; eyes_shut gate added")
