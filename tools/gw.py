"""pc-automations gateway MCP client (Zoud project copy).

Usage:
  gw.py call  <tool> <args.json>          -> one tools/call, prints result text (truncated 3000)
  gw.py batch <spec1.json> [spec2.json..] -> specs are {"tool":..., "arguments": {...}}
  gw.py fetch <remote-path> <local-path>  -> chunked base64 download via blender_execute_bpy

Token is read from stdin (first line) — never pass it as an argument or store it.
Access path: runtime HTTP proxy with port swapped to 3130 (Tailscale proxy),
gateway at the laptop tailnet IP 100.121.94.80:8930.
"""
import sys, os, json, urllib.request, base64

GW_URL = "http://100.121.94.80:8930/mcp"

def make_opener():
    base_proxy = os.environ.get("HTTPS_PROXY", "")
    proxy = base_proxy.rsplit(":", 1)[0] + ":3130" if base_proxy else None
    return urllib.request.build_opener(urllib.request.ProxyHandler({"http": proxy, "https": proxy}))

class Session:
    def __init__(self, token):
        self.token = token
        self.opener = make_opener()
        self.session = None
        self._id = 0
    def post(self, payload):
        data = json.dumps(payload).encode()
        req = urllib.request.Request(GW_URL, data=data, method="POST")
        req.add_header("Content-Type", "application/json")
        req.add_header("Accept", "application/json, text/event-stream")
        req.add_header("Authorization", "Bearer " + self.token)
        if self.session:
            req.add_header("Mcp-Session-Id", self.session)
        try:
            resp = self.opener.open(req, timeout=1200)
            sid = resp.headers.get("Mcp-Session-Id")
            if sid:
                self.session = sid
            return resp.status, resp.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode("utf-8", "replace")[:2000]
    @staticmethod
    def parse_rpc(body):
        for line in body.splitlines():
            if line.startswith("data:"):
                try:
                    return json.loads(line[5:].strip())
                except Exception:
                    pass
        try:
            return json.loads(body)
        except Exception:
            return {"raw": body[:1000]}
    def init(self):
        status, body = self.post({"jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2025-03-26", "capabilities": {},
                       "clientInfo": {"name": "zoud-gw", "version": "1.0"}}})
        assert status == 200, (status, body[:400])
        self.post({"jsonrpc": "2.0", "method": "notifications/initialized"})
    def call(self, tool, args):
        self._id += 10
        status, body = self.post({"jsonrpc": "2.0", "id": self._id, "method": "tools/call",
                                  "params": {"name": tool, "arguments": args}})
        rpc = self.parse_rpc(body)
        res = rpc.get("result") or {}
        texts = [c["text"] for c in res.get("content") or [] if c.get("type") == "text"]
        return status, res.get("isError"), "\n".join(texts), rpc

def main():
    token = sys.stdin.readline().strip()
    mode = sys.argv[1]
    s = Session(token)
    s.init()
    if mode == "call":
        args = json.load(open(sys.argv[3]))
        status, iserr, text, _ = s.call(sys.argv[2], args)
        print("STATUS", status, "isError:", iserr)
        print(text[:3000])
    elif mode == "batch":
        for path in sys.argv[2:]:
            spec = json.load(open(path))
            status, iserr, text, _ = s.call(spec["tool"], spec["arguments"])
            print(os.path.basename(path), "->", text[:600])
            sys.stdout.flush()
    elif mode == "fetch":
        remote, local = sys.argv[2], sys.argv[3]
        def bpy(code):
            status, iserr, text, _ = s.call("blender_execute_bpy", {"code": code, "preview": False})
            payload = json.loads(text)
            assert payload.get("ok"), payload
            return payload["result"]
        total = bpy("import os\nresult = {'size': os.path.getsize(%r)}\n" % remote)["size"]
        print("remote size:", total)
        CH = 60000
        parts, got = [], 0
        while True:
            r = bpy("import base64\n"
                    "data = base64.b64encode(open(%r,'rb').read()).decode()\n"
                    "result = {'chunk': data[%d:%d], 'total_b64': len(data)}\n" % (remote, got, got + CH))
            if not r["chunk"]:
                break
            parts.append(r["chunk"])
            got += len(r["chunk"])
            if got >= r["total_b64"]:
                break
        raw = base64.b64decode("".join(parts))
        os.makedirs(os.path.dirname(local), exist_ok=True)
        with open(local, "wb") as f:
            f.write(raw)
        print("wrote", local, len(raw), "bytes")
    else:
        print("unknown mode", mode); sys.exit(2)

if __name__ == "__main__":
    main()
