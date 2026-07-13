#!/bin/bash

# 启用开源 WiFi 驱动脚本
# 适用于 Oray X1Pro 编译配置

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/X1ProUBoot.config"
FILEOGIC_MK="$SCRIPT_DIR/filogic.mk"

echo "=== 启用开源 WiFi 驱动 ==="
echo ""

# 备份原文件
echo "[1/3] 备份原文件..."
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
cp "$FILEOGIC_MK" "$FILEOGIC_MK.backup"
echo "✓ 备份完成"
echo ""

# 修改 filogic.mk
echo "[2/3] 修改 filogic.mk..."
sed -i '' 's/DEVICE_PACKAGES := kmod-usb3 automount kmod-mt_wifi wifi-dats/DEVICE_PACKAGES := kmod-usb3 automount kmod-mt76/g' "$FILEOGIC_MK"
echo "✓ filogic.mk 已修改"
echo ""

# 修改配置文件
echo "[3/3] 修改配置文件..."
# 禁用闭源驱动
sed -i '' 's/CONFIG_PACKAGE_kmod-mt_wifi=y/# CONFIG_PACKAGE_kmod-mt_wifi is not set/g' "$CONFIG_FILE"
# 启用开源驱动
sed -i '' 's/# CONFIG_DEFAULT_kmod-mt7915e is not set/CONFIG_DEFAULT_kmod-mt7915e=y/g' "$CONFIG_FILE"
echo "✓ 配置文件已修改"
echo ""

echo "=== 修改完成 ==="
echo ""
echo "修改内容："
echo "  - filogic.mk: kmod-mt_wifi → kmod-mt76"
echo "  - X1ProUBoot.config: 启用 kmod-mt7915e"
echo ""
echo "备份文件："
echo "  - $CONFIG_FILE.backup"
echo "  - $FILEOGIC_MK.backup"
echo ""
echo "请运行以下命令重新编译："
echo "  git add -A && git commit -m '启用开源WiFi驱动' && git push"
