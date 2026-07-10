#!/bin/bash
# DIY Part 1: X1 Pro device setup
# 原则：最小化侵入，只 patch 不改写上游文件
set -euo pipefail

WORKSPACE="$GITHUB_WORKSPACE"
OPENWRT="$WORKSPACE/openwrt"

echo "=== DIY Part 1: X1 Pro setup ==="

# 1. Copy DTS files
DTS_DIR="$OPENWRT/target/linux/mediatek/files/arch/arm64/boot/dts/mediatek/"
mkdir -p "$DTS_DIR"

for f in mt7981b-oray-x1pro-v1.dtsi mt7981b-oray-x1pro-v1.dts mt7981b-oray-x1pro-v1-ubootmod.dts; do
  if [ -f "$WORKSPACE/$f" ]; then
    cp "$WORKSPACE/$f" "$DTS_DIR"
    echo "  → $f"
  fi
done

# 2. Patch filogic.mk
if [ -f "$WORKSPACE/filogic.mk" ]; then
  cp "$WORKSPACE/filogic.mk" "$OPENWRT/target/linux/mediatek/filogic.mk"
  echo "  → filogic.mk patched"
fi

# 3. Patch upstream 02_network — 只加接口定义，MAC 由 DTS 提供
#    X1 Pro: eth1=LAN, eth0=WAN（与 TR3000 相同）
NETWORK_FILE="$OPENWRT/target/linux/mediatek/filogic/base-files/etc/board.d/02_network"
if [ -f "$NETWORK_FILE" ]; then
  python3 -c '
import sys
f = sys.argv[1]
with open(f) as fh:
    lines = fh.readlines()

out = []
for line in lines:
    out.append(line)
    if line.rstrip() == "\tcudy,tr3000-v1-ubootmod|\\":
        out.append("\toray,x1pro-v1|\\\n")
        out.append("\toray,x1pro-v1-ubootmod|\\\n")

with open(f, "w") as fh:
    fh.writelines(out)
' "$NETWORK_FILE"
  echo "  → 02_network patched (X1 Pro interfaces added)"
else
  echo "  ⚠ 02_network not found at $NETWORK_FILE"
fi

# 4. Patch platform.sh — sysupgrade 支持
PLATFORM_FILE="$OPENWRT/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh"
if [ -f "$PLATFORM_FILE" ]; then
  python3 -c '
import sys
f = sys.argv[1]
with open(f) as fh:
    content = fh.read()

old = "\tcudy,wbr3000uax-v1-ubootmod|\\\n"
new = "\tcudy,wbr3000uax-v1-ubootmod|\\\n\toray,x1pro-v1-ubootmod|\\\n"
if old in content:
    content = content.replace(old, new, 1)
    with open(f, "w") as fh:
        fh.write(content)
    print("ok")
else:
    print("already patched or not found")
' "$PLATFORM_FILE"
  echo "  → platform.sh patched"
fi

echo "=== DIY Part 1 done ==="
