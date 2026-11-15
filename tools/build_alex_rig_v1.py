"""Assemble Alex V1's despilled paper-doll layers into a standing bind pose
and author the rig2d rig (layers + pivots + FK parents + rig.json).

Doll canvas: 1920x1280 (exploded layout, parts scattered). Rig canvas:
1920x1600 (standing). Placement is per-part translate only (rotation 0):
the V1 doll's arm chains hang vertical, so chains are rebuilt by landing
each piece's pivot on its joint point (shoulder -> elbow -> wrist), with
a 30 px cap overlap at elbow/wrist so the rounded joint caps seat.
Legs are bottom-aligned (both doll legs end at y=981; their tops differ
because leg_R's dome was trimmed at Gate 1 — the difference hides under
the apron hem). Shoes overlap the ankle notch by 35 px.
"""
import json, os
from PIL import Image

SRC = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA_v1/alex_layers_despilled"
OUT = "/home/hatch/workspace/zoud-gamelab/assets/character/rig_alex_v1"
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

def T(p, D):
    return [round(p[0] + D[0], 1), round(p[1] + D[1], 1)]

P = {k: v["pivot"] for k, v in pivots.items()}

# ---------- placement plan (doll coords -> rig coords) ----------
HEAD_D = (651, 44)          # face pivot (309,376) -> (960,420)
NECK_D = (-23, 320)         # neck bbox -> x 892..1027, y 395..526 (rim hides behind jaw)
TORSO_D = (653.5, 11)       # torso pivot -> (960,870); bbox y 451..870
POCKET_D = (653, -184)      # pocket pivot -> (960,724); pocket y 724..870 (flush at hem)
LEG_DY = 329                # both legs: doll bottom 981 -> rig ankle line 1310 (legs ride 20 up so leg_R's skin cap stays behind the apron hem)
LEG_L_D = (-116, LEG_DY)    # pivot -> (875,749)
LEG_R_D = (-180.5, LEG_DY)  # pivot -> (1045,835)
SHOE_L_D = (-604, 527)      # pivot -> (875,1275): 35 px over the ankle notch
SHOE_R_D = (-700, 525)      # pivot -> (1045,1275)
# arm chains: A -> character right (viewer-left), B -> character left
ARM_R_SHOULDER = (730, 470)
ARM_L_SHOULDER = (1190, 470)
CAP = 30  # joint-cap overlap at elbow and wrist

def chain_ds(pre, shoulder):
    """Translations for (upper, forearm, hand) landing pivots on the joints."""
    up_p, fo_p, ha_p = P[f"upper_arm_{pre}"], P[f"forearm_{pre}"], P[f"hand_{pre}"]
    # piece lengths pivot->bbox bottom, from the assemble pivots + known bboxes
    up_len = {"A": 803, "B": 411}[pre] - up_p[1]
    fo_len = {"A": 725, "B": 408}[pre] - fo_p[1]
    elbow = (shoulder[0], shoulder[1] + up_len - CAP)
    wrist = (elbow[0], elbow[1] + fo_len - CAP)
    return ((shoulder[0] - up_p[0], shoulder[1] - up_p[1]),
            (elbow[0] - fo_p[0], elbow[1] - fo_p[1]),
            (wrist[0] - ha_p[0], wrist[1] - ha_p[1]))

ARM_R_DS = chain_ds("A", ARM_R_SHOULDER)
ARM_L_DS = chain_ds("B", ARM_L_SHOULDER)

rig_layers = []
def add(out_id, img, pivot, parent=None):
    rig_layers.append((out_id, img, [round(float(pivot[0]), 1), round(float(pivot[1]), 1)], parent))
    img.save(f"{OUT}/layers/{out_id}.png")

# legs + shoes
add("leg_L", translate(load("leg_L"), *LEG_L_D), T(P["leg_L"], LEG_L_D), "torso")
add("leg_R", translate(load("leg_R"), *LEG_R_D), T(P["leg_R"], LEG_R_D), "torso")
add("shoe_L", translate(load("shoe_L"), *SHOE_L_D), T(P["shoe_L"], SHOE_L_D), "leg_L")
add("shoe_R", translate(load("shoe_R"), *SHOE_R_D), T(P["shoe_R"], SHOE_R_D), "leg_R")
# torso + pocket
add("torso", translate(load("torso"), *TORSO_D), (960, 870), None)
add("apron_pocket", translate(load("apron_pocket"), *POCKET_D), T(P["apron_pocket"], POCKET_D), "torso")
# head cluster
add("neck", translate(load("neck"), *NECK_D), T(P["neck"], NECK_D), "torso")
add("face", translate(load("face"), *HEAD_D), (960, 420), "torso")
add("hair", translate(load("hair"), *HEAD_D), (960, 420), "face")
add("eye_r", translate(load("eye_r"), *HEAD_D), T(P["eye_r"], HEAD_D), "face")
add("eye_l", translate(load("eye_l"), *HEAD_D), T(P["eye_l"], HEAD_D), "face")
# arm chains
for chain, pre, DS in [("r", "A", ARM_R_DS), ("l", "B", ARM_L_DS)]:
    add(f"upper_arm_{chain}", translate(load(f"upper_arm_{pre}"), *DS[0]), T(P[f"upper_arm_{pre}"], DS[0]), "torso")
    add(f"forearm_{chain}", translate(load(f"forearm_{pre}"), *DS[1]), T(P[f"forearm_{pre}"], DS[1]), f"upper_arm_{chain}")
    add(f"hand_{chain}", translate(load(f"hand_{pre}"), *DS[2]), T(P[f"hand_{pre}"], DS[2]), f"forearm_{chain}")

ORDER = ["leg_L", "leg_R", "shoe_L", "shoe_R", "torso", "apron_pocket", "neck",
         "face", "hair", "upper_arm_r", "forearm_r", "hand_r",
         "upper_arm_l", "forearm_l", "hand_l", "eye_r", "eye_l"]
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
        "shoulder_r": {"default": 0.0, "min": -1.0, "max": 1.0},
        "elbow_r": {"default": 0.0, "min": -1.0, "max": 1.0},
        "shoulder_l": {"default": 0.0, "min": -1.0, "max": 1.0},
        "elbow_l": {"default": 0.0, "min": -1.0, "max": 1.0},
    },
    "bindings": [
        {"target": "layer:torso", "param": "breath", "op": "scale_y", "scale": 0.03},
        {"target": "layer:face", "param": "tilt", "op": "rotate", "scale": 6.0},
        {"target": "layer:upper_arm_r", "param": "shoulder_r", "op": "rotate", "scale": 55.0},
        {"target": "layer:forearm_r", "param": "elbow_r", "op": "rotate", "scale": -50.0},
        {"target": "layer:upper_arm_l", "param": "shoulder_l", "op": "rotate", "scale": -55.0},
        {"target": "layer:forearm_l", "param": "elbow_l", "op": "rotate", "scale": 50.0},
    ],
}
json.dump(rig, open(OUT + "/rig.json", "w"), indent=1)
json.dump({"name": "bind", "fps": 12, "frames": 2, "tracks": {}}, open(OUT + "/bind.motion.json", "w"))

canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
for oid in ORDER:
    canvas.alpha_composite(Image.open(f"{OUT}/layers/{oid}.png").convert("RGBA"))
prev = Image.new("RGBA", (W, H), (40, 42, 48, 255))
prev.alpha_composite(canvas)
prev.convert("RGB").save(OUT + "/bind_preview.png")
print("rig written:", OUT, "layers:", len(ORDER))
for oid in ORDER:
    print(" ", oid, "pivot", by_id[oid][2], "parent", by_id[oid][3])
