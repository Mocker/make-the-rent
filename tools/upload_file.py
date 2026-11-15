"""Upload a local file to the laptop via gateway blender_execute_bpy,
chunked base64 append. Token from stdin line 1 (never an argument)."""
import sys, os, json, base64
sys.path.insert(0, "/home/hatch/workspace/zoud-gamelab/tools")
from gw import Session

token = sys.stdin.readline().strip()
local, remote = sys.argv[1], sys.argv[2]
s = Session(token)
s.init()

def bpy(code):
    status, iserr, text, _ = s.call("blender_execute_bpy", {"code": code, "preview": False})
    payload = json.loads(text)
    assert payload.get("ok"), payload
    return payload["result"]

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
print("remote size:", size, "local size:", os.path.getsize(local))
assert size == os.path.getsize(local)
print("UPLOAD OK")
