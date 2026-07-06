#!/bin/bash
#
# Combined DIY Part 1 Script
# Handles: custom packages + theme cloning
# DTS 和 filogic.mk 设备定义由 workflow 直接复制，不再通过本脚本追加
#
set -x
WORKSPACE="$GITHUB_WORKSPACE"

# Copy custom local packages into OpenWrt tree
if [ -d "$GITHUB_WORKSPACE/package/luci-compat-keep" ]; then
  mkdir -p package
  cp -r "$GITHUB_WORKSPACE/package/luci-compat-keep" package/
fi

# Clone theme packages (idempotent - only clone if not present)
[ -d "package/luci-theme-aurora" ] || git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
[ -d "package/luci-app-aurora-config" ] || git clone https://github.com/eamonxg/luci-app-aurora-config package/luci-app-aurora-config
[ -d "package/luci-app-bandix" ] || git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
[ -d "package/openwrt-bandix" ] || git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
