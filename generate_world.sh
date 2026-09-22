#!/usr/bin/env bash
set -euo pipefail
WORLD="ABSURD_1.20.1_Forge_World"
python3 - <<'PY'
import json, urllib.request
manifest=json.load(urllib.request.urlopen("https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"))
v=next(x for x in manifest["versions"] if x["id"]=="1.20.1")
info=json.load(urllib.request.urlopen(v["url"]))
urllib.request.urlretrieve(info["downloads"]["server"]["url"],"server.jar")
PY
printf 'eula=true\n' > eula.txt
cat > server.properties <<'EOF'
level-name=ABSURD_1.20.1_Forge_World
level-seed=4453
gamemode=creative
force-gamemode=true
difficulty=normal
allow-flight=true
enable-command-block=true
spawn-protection=0
level-type=minecraft:normal
generate-structures=true
online-mode=false
max-players=1
view-distance=8
simulation-distance=6
EOF
java -Xmx2G -Xms1G -jar server.jar nogui &
PID=$!
for i in $(seq 1 180); do [ -f "$WORLD/level.dat" ] && break; sleep 2; done
sleep 10
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
mkdir -p dist
zip -qr "dist/Absurd_1.20.1_Forge_World.zip" "$WORLD"
