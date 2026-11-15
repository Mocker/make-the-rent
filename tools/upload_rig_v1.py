"""Upload the rig_alex_v1 rig files to the laptop for gateway validation.
Token from stdin line 1 (never an argument)."""
import sys, os, json, base64
sys.path.insert(0, "/home/hatch/workspace/zoud-gamelab/tools")
from gw import Session

token = sys.stdin.readline().strip()
LOCAL = "/home/hatch/workspace/zoud-gamelab/assets/character/rig_alex_v1"
REMOTE = "G:\\Dev\\10_Projects\\pc-automations\\zoud\\rig_alex_v1"
s = Session(token)
s.init()

def bpy(code):
    status, iserr, text, _ = s.call("blender_execute_bpy", {"code": code, "preview": False})
    payload = json.loads(text)
    assert payload.get("ok"), payload
    return payload["result"]

bpy("import os\nos.makedirs(%r, exist_ok=True)\nos.makedirs(%r, exist_ok=True)\nresult = {'ok': True}\n"
    % (REMOTE, REMOTE + "\\layers"))

files = ["rig.json", "bind.motion.json", "stress.motion.json", "blinktest.motion.json"]
files += [f"layers/{n}" for n in sorted(os.listdir(LOCAL + "/layers")) if n.endswith(".png")]
for rel in files:
    local = os.path.join(LOCAL, rel)
    remote = REMOTE + "\\" + rel.replace("/", "\\")
    data = base64.b64encode(open(local, "rb").read()).decode()
    bpy("open(%r, 'wb').close()\nresult = {'ok': True}\n" % remote)
    CH = 40000
    for i in range(0, len(data), CH):
        chunk = data[i:i + CH]
        bpy("import base64\n"
            "with open(%r, 'ab') as f:\n"
            "    f.write(base64.b64decode(%r))\n"
            "result = {'written_to': %d}\n" % (remote, chunk, i + len(chunk)))
    size = bpy("import os\nresult = {'size': os.path.getsize(%r)}\n" % remote)["size"]
    assert size == os.path.getsize(local), (rel, size, os.path.getsize(local))
    print("uploaded", rel, size)
    sys.stdout.flush()
print("RIG UPLOAD OK")
