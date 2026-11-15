import subprocess, sys, os
token = sys.stdin.readline()
GW = "/home/hatch/workspace/zoud-gamelab/tools/gw.py"
REMOTE_DIR = "G:\\Dev\\10_Projects\\pc-automations\\zoud\\alex_layers_v1"
LOCAL_DIR = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA_v1/alex_layers_raw"
layers = ["leg_L", "leg_R", "shoe_L", "shoe_R", "torso", "apron_pocket", "neck", "face", "hair",
          "upper_arm_A", "forearm_A", "hand_A", "upper_arm_B", "forearm_B", "hand_B", "eye_r", "eye_l"]
os.makedirs(LOCAL_DIR + "/layers", exist_ok=True)
targets = [(f"{REMOTE_DIR}\\layers\\{n}.png", f"{LOCAL_DIR}/layers/{n}.png") for n in layers]
targets.append((f"{REMOTE_DIR}\\pivots.json", f"{LOCAL_DIR}/pivots.json"))
for remote, local in targets:
    r = subprocess.run(["python3", GW, "fetch", remote, local], input=token, capture_output=True, text=True, timeout=900)
    out = r.stdout.strip().splitlines()
    print(os.path.basename(local), "->", out[-1] if out else ("ERR " + r.stderr[-200:]))
    sys.stdout.flush()
