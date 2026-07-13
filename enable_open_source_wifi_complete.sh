#!/bin/bash

# 启用开源 WiFi 驱动脚本（完整版）
# 禁用所有 MTK 闭源驱动相关包

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/X1ProUBoot.config"
FILEOGIC_MK="$SCRIPT_DIR/filogic.mk"

echo "=== 启用开源 WiFi 驱动（完整版）==="
echo ""

# 备份原文件
echo "[1/3] 备份原文件..."
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
cp "$FILEOGIC_MK" "$FILEOGIC_MK.backup"
echo "✓ 备份完成"
echo ""

# 修改 filogic.mk
echo "[2/3] 修改 filogic.mk..."
# 修改设备包定义
sed -i '' 's/DEVICE_PACKAGES := kmod-usb3 automount kmod-mt_wifi wifi-dats/DEVICE_PACKAGES := kmod-usb3 automount kmod-mt76/g' "$FILEOGIC_MK"
echo "✓ filogic.mk 已修改"
echo ""

# 修改配置文件 - 禁用闭源驱动相关包
echo "[3/3] 修改配置文件..."

# 1. 禁用闭源 WiFi 驱动模块
sed -i '' 's/CONFIG_PACKAGE_kmod-mt_wifi=y/# CONFIG_PACKAGE_kmod-mt_wifi is not set/g' "$CONFIG_FILE"

# 2. 禁用 wifi-dats（闭源驱动固件数据）
sed -i '' 's/CONFIG_PACKAGE_wifi-dats=y/# CONFIG_PACKAGE_wifi-dats is not set/g' "$CONFIG_FILE"

# 3. 禁用闭源驱动配置工具
sed -i '' 's/CONFIG_PACKAGE_mtwifi-cfg=y/# CONFIG_PACKAGE_mtwifi-cfg is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_PACKAGE_luci-app-mtwifi-cfg=y/# CONFIG_PACKAGE_luci-app-mtwifi-cfg is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_PACKAGE_luci-i18n-mtwifi-cfg-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-mtwifi-cfg-zh-cn is not set/g' "$CONFIG_FILE"

# 4. 禁用 conninfra（闭源驱动依赖）
sed -i '' 's/CONFIG_PACKAGE_kmod-conninfra=y/# CONFIG_PACKAGE_kmod-conninfra is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_MTK_CONNINFRA_APSOC=y/# CONFIG_MTK_CONNINFRA_APSOC is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_MTK_CONNINFRA_APSOC_MT7981=y/# CONFIG_MTK_CONNINFRA_APSOC_MT7981 is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_CONNINFRA_EMI_SUPPORT=y/# CONFIG_CONNINFRA_EMI_SUPPORT is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_CONNINFRA_AUTO_UP=y/# CONFIG_CONNINFRA_AUTO_UP is not set/g' "$CONFIG_FILE"

# 5. 禁用 WARP 硬件加速（闭源驱动专用）
sed -i '' 's/CONFIG_MTK_WARP_V2=y/# CONFIG_MTK_WARP_V2 is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_PACKAGE_kmod-warp=y/# CONFIG_PACKAGE_kmod-warp is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_WARP_DBG_SUPPORT=y/# CONFIG_WARP_DBG_SUPPORT is not set/g' "$CONFIG_FILE"

# 6. 禁用 MTK MT_WIFI 内置选项
sed -i '' 's/CONFIG_MTK_MT_WIFI=m/# CONFIG_MTK_MT_WIFI is not set/g' "$CONFIG_FILE"
sed -i '' 's/CONFIG_MTK_MT_WIFI_PATH="mt_wifi"/# CONFIG_MTK_MT_WIFI_PATH is not set/g' "$CONFIG_FILE"

# 7. 启用开源驱动
# 添加开源驱动配置（如果不存在）
if ! grep -q "^CONFIG_PACKAGE_kmod-mt76=" "$CONFIG_FILE"; then
    echo "CONFIG_PACKAGE_kmod-mt76=y" >> "$CONFIG_FILE"
else
    sed -i '' 's/# CONFIG_PACKAGE_kmod-mt76 is not set/CONFIG_PACKAGE_kmod-mt76=y/g' "$CONFIG_FILE"
    sed -i '' 's/CONFIG_PACKAGE_kmod-mt76=m/CONFIG_PACKAGE_kmod-mt76=y/g' "$CONFIG_FILE"
fi

# 启用 MT7915E 驱动（X1Pro 使用的芯片）
sed -i '' 's/# CONFIG_DEFAULT_kmod-mt7915e is not set/CONFIG_DEFAULT_kmod-mt7915e=y/g' "$CONFIG_FILE"
if ! grep -q "^CONFIG_DEFAULT_kmod-mt7915e=" "$CONFIG_FILE"; then
    echo "CONFIG_DEFAULT_kmod-mt7915e=y" >> "$CONFIG_FILE"
fi

echo "✓ 配置文件已修改"
echo ""

echo "=== 修改完成 ==="
echo ""
echo "已禁用的闭源驱动包："
echo "  ✓ kmod-mt_wifi"
echo "  ✓ wifi-dats"
echo "  ✓ mtwifi-cfg"
echo "  ✓ luci-app-mtwifi-cfg"
echo "  ✓ luci-i18n-mtwifi-cfg-zh-cn"
echo "  ✓ kmod-conninfra"
echo "  ✓ kmod-warp"
echo ""
echo "已启用的开源驱动："
echo "  ✓ kmod-mt76"
echo "  ✓ kmod-mt7915e"
echo ""
echo "备份文件："
echo "  - $CONFIG_FILE.backup"
echo "  - $FILEOGIC_MK.backup"
echo ""
echo "下一步："
echo "  git add -A"
echo "  git commit -m '启用开源 WiFi 驱动并禁用所有闭源驱动包'"
echo "  git push"
