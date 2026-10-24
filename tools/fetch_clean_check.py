import subprocess, sys, os
token = sys.stdin.readline()
GW = "/home/hatch/workspace/zoud-gamelab/tools/gw.py"
REMOTE_DIR = "G:\\Dev\\10_Projects\\pc-automations\\zoud\\alex_layers_clean"
LOCAL_DIR = "/home/hatch/workspace/zoud-gamelab/assets/character/stageA/alex_layers_clean"
os.makedirs(LOCAL_DIR + "/layers", exist_ok=True)
for n in ["hand_A", "hand_B", "hair", "shoe_L", "shoe_R", "face"]:
    remote = f"{REMOTE_DIR}\\layers\\{n}.png"
    local = f"{LOCAL_DIR}/layers/{n}.png"
    r = subprocess.run(["python3", GW, "fetch", remote, local], input=token, capture_output=True, text=True, timeout=900)
    out = r.stdout.strip().splitlines()
    print(n, "->", out[-1] if out else ("ERR " + r.stderr[-200:]))
    sys.stdout.flush()
