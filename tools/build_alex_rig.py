"""Assemble Alex's despilled paper-doll layers into a standing bind pose and
author the rig2d rig (layers + pivots + FK parents + rig.json).

Doll canvas: 1920x1280 (exploded layout). Rig canvas: 1920x1600 (standing).
Transforms: per-part translate; arm chains additionally rotate rigidly around
the shoulder joint so joints stay attached.
"""
import json, math, os
from PIL import Image

SRC = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA/alex_layers_despilled"
OUT = "/home/hatch/workspace/zoud-gamelab/assets/character/rig_alex"
os.makedirs(OUT + "/layers", exist_ok=True)
W, H = 1920, 1600
pivots = json.load(open(SRC + "/pivots.json"))["parts"]

def load(name):
    return Image.open(f"{SRC}/layers/{name}.png").convert("RGBA")

def translate(img, dx, dy):
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    tmp = Image.new("RGBA", (1920, 1280), (0, 0, 0, 0))
    tmp.alpha_composite(img)
    out.alpha_composite(tmp, (int(round(dx)), int(round(dy))))
    return out

def rot_point(px, py, cx, cy, deg):
    """Rotate point around center by deg (PIL Image.rotate convention:
    positive angle = counter-clockwise in image space as displayed)."""
    t = math.radians(deg)
    # PIL rotate moves pixels counter-clockwise around center in a y-down
    # coordinate system, which is a clockwise rotation in math coords.
    x, y = px - cx, py - cy
    xr = x * math.cos(t) + y * math.sin(t)
    yr = -x * math.sin(t) + y * math.cos(t)
    return (cx + xr, cy + yr)

def rotate_about(img, cx, cy, deg):
    return img.rotate(deg, resample=Image.BICUBIC, center=(cx, cy))

# ---------- placement plan (doll coords -> rig coords) ----------
# Head cluster: translate only. Hair top doll y=32 -> rig y=40.
HEAD_D = (614, 8)
# Torso: dx 0, dy +403 (neck opening doll y~57 -> 460, under the neck joint)
TORSO_D = (0, 403)
# Legs: pivots to hips (866,875) / (1066,875)
LEG_L_D = (866 - 740.5, 875 - 531)
LEG_R_D = (1066 - 1192.0, 875 - 531)
# Shoes: pivots to ankles (855,1405) / (1077,1405)
SHOE_L_D = (855 - 360.0, 1405 - 1091)
SHOE_R_D = (1077 - 1559.5, 1405 - 1090)
# Arm A (character right): shoulder doll (560,560) -> rig (716,520), rotate -58 deg
ARM_R_JOINT_DOLL = (560, 560)
ARM_R_JOINT = (716, 520)
ARM_R_D = (ARM_R_JOINT[0] - ARM_R_JOINT_DOLL[0], ARM_R_JOINT[1] - ARM_R_JOINT_DOLL[1])
ARM_R_ROT = 0
# Arm B (character left): shoulder doll (1405,205) -> rig (1216,520), rotate +10 deg
ARM_L_JOINT_DOLL = (1405, 205)
ARM_L_JOINT = (1216, 520)
ARM_L_D = (ARM_L_JOINT[0] - ARM_L_JOINT_DOLL[0], ARM_L_JOINT[1] - ARM_L_JOINT_DOLL[1])
ARM_L_ROT = 0

def arm_place(img, D, joint_rig, deg):
    moved = translate(img, D[0], D[1])
    return rotate_about(moved, joint_rig[0], joint_rig[1], deg)

def arm_pivot(p, D, joint_doll, joint_rig, deg):
    px, py = p[0] + D[0], p[1] + D[1]
    if (round(p[0]), round(p[1])) == joint_doll:
        return [joint_rig[0], joint_rig[1]]
    xr, yr = rot_point(px, py, joint_rig[0], joint_rig[1], deg)
    return [round(xr, 1), round(yr, 1)]

rig_layers = []   # (out_id, image, pivot, parent)
def add(out_id, img, pivot, parent=None):
    rig_layers.append((out_id, img, [round(float(pivot[0]), 1), round(float(pivot[1]), 1)], parent))
    img.save(f"{OUT}/layers/{out_id}.png")

def T(p, D):
    return [p[0] + D[0], p[1] + D[1]]

P = {k: v["pivot"] for k, v in pivots.items()}

# legs + shoes
add("leg_L", translate(load("leg_L"), *LEG_L_D), (866, 875), "torso")
add("leg_R", translate(load("leg_R"), *LEG_R_D), (1066, 875), "torso")
add("shoe_L", translate(load("shoe_L"), *SHOE_L_D), T(P["shoe_L"], SHOE_L_D), "leg_L")
add("shoe_R", translate(load("shoe_R"), *SHOE_R_D), T(P["shoe_R"], SHOE_R_D), "leg_R")
# torso
add("torso", translate(load("torso"), *TORSO_D), (966, 925), None)
# head cluster (parent: neck/face -> torso; hair/ears/eyes -> face)
add("neck", translate(load("neck"), *HEAD_D), T(P["neck"], HEAD_D), "torso")
add("face", translate(load("face"), *HEAD_D), (966, 460), "torso")
add("ear_r", translate(load("ear_r"), *HEAD_D), T(P["ear_r"], HEAD_D), "face")
add("ear_l", translate(load("ear_l"), *HEAD_D), T(P["ear_l"], HEAD_D), "face")
add("hair", translate(load("hair"), *HEAD_D), (966, 460), "face")
add("eye_r", translate(load("eye_r"), *HEAD_D), T(P["eye_r"], HEAD_D), "face")
add("eye_l", translate(load("eye_l"), *HEAD_D), T(P["eye_l"], HEAD_D), "face")
# arm chains
for chain, pre, D, jd, jr, deg in [
    ("r", "A", ARM_R_D, ARM_R_JOINT_DOLL, ARM_R_JOINT, ARM_R_ROT),
    ("l", "B", ARM_L_D, ARM_L_JOINT_DOLL, ARM_L_JOINT, ARM_L_ROT),
]:
    up = arm_place(load(f"upper_arm_{pre}"), D, jr, deg)
    fo = arm_place(load(f"forearm_{pre}"), D, jr, deg)
    ha = arm_place(load(f"hand_{pre}"), D, jr, deg)
    fo_piv = arm_pivot(P[f"forearm_{pre}"], D, jd, jr, deg)
    ha_piv = arm_pivot(P[f"hand_{pre}"], D, jd, jr, deg)
    if chain == "l":
        # doll gap between upper and forearm widens under rotation; tuck
        # forearm+hand back toward the elbow
        nudge = (-8, -34)
        fo = translate(fo, *nudge)
        ha = translate(ha, *nudge)
        fo_piv = [fo_piv[0] + nudge[0], fo_piv[1] + nudge[1]]
        ha_piv = [ha_piv[0] + nudge[0], ha_piv[1] + nudge[1]]
    if chain == "r":
        # doll draws forearm A offset down-left of the upper arm's end;
        # tuck it up against the elbow
        nudge = (-70, -55)
        fo = translate(fo, *nudge)
        ha = translate(ha, *nudge)
        fo_piv = [fo_piv[0] + nudge[0], fo_piv[1] + nudge[1]]
        ha_piv = [ha_piv[0] + nudge[0], ha_piv[1] + nudge[1]]
    add(f"upper_arm_{chain}", up, jr, "torso")
    add(f"forearm_{chain}", fo, fo_piv, f"upper_arm_{chain}")
    add(f"hand_{chain}", ha, ha_piv, f"forearm_{chain}")

ORDER = ["leg_L", "leg_R", "shoe_L", "shoe_R", "torso", "neck", "face",
         "ear_r", "ear_l", "hair", "eye_r", "eye_l",
         "upper_arm_r", "forearm_r", "hand_r", "upper_arm_l", "forearm_l", "hand_l"]
by_id = {l[0]: l for l in rig_layers}
layers_json = []
for oid in ORDER:
    _, _, piv, parent = by_id[oid]
    entry = {"id": oid, "src": f"layers/{oid}.png", "pivot": piv}
    if parent:
        entry["parent"] = parent
    layers_json.append(entry)

rig = {
    "name": "alex",
    "canvas": [W, H],
    "motions": ["bind"],
    "layers": layers_json,
    "parameters": {
        "breath": {"default": 0.0, "min": -1.0, "max": 1.0},
        "tilt": {"default": 0.0, "min": -1.0, "max": 1.0},
        "blink": {"default": 0.0, "min": 0.0, "max": 1.0},
        "shoulder_r": {"default": 0.0, "min": -1.0, "max": 1.0},
        "elbow_r": {"default": 0.0, "min": -1.0, "max": 1.0},
        "shoulder_l": {"default": 0.0, "min": -1.0, "max": 1.0},
        "elbow_l": {"default": 0.0, "min": -1.0, "max": 1.0},
    },
    "bindings": [
        {"target": "layer:torso", "param": "breath", "op": "scale_y", "scale": 0.03},
        {"target": "layer:face", "param": "tilt", "op": "rotate", "scale": 6.0},
        {"target": "layer:eye_r", "param": "blink", "op": "scale_y", "scale": -0.92},
        {"target": "layer:eye_l", "param": "blink", "op": "scale_y", "scale": -0.92},
        {"target": "layer:upper_arm_r", "param": "shoulder_r", "op": "rotate", "scale": 55.0},
        {"target": "layer:forearm_r", "param": "elbow_r", "op": "rotate", "scale": -50.0},
        {"target": "layer:upper_arm_l", "param": "shoulder_l", "op": "rotate", "scale": -55.0},
        {"target": "layer:forearm_l", "param": "elbow_l", "op": "rotate", "scale": 50.0},
    ],
}
json.dump(rig, open(OUT + "/rig.json", "w"), indent=1)
json.dump({"name": "bind", "fps": 12, "frames": 2, "tracks": {}}, open(OUT + "/bind.motion.json", "w"))

# bind composite preview
canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
for oid in ORDER:
    canvas.alpha_composite(Image.open(f"{OUT}/layers/{oid}.png").convert("RGBA"))
prev = Image.new("RGBA", (W, H), (40, 42, 48, 255))
prev.alpha_composite(canvas)
prev.convert("RGB").save(OUT + "/bind_preview.png")
print("rig written:", OUT, "layers:", len(ORDER))
