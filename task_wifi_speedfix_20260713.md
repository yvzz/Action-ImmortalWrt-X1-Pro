# WiFi/有线速度修复 — 2026-07-13

## 根因
MT7981 硬件加速体系的核心驱动 `mediatek_hnat`（PPE + WED 硬件卸载）未编译。

### 加速架构（MT7981）
```
WiFi → WED (Wireless Edge DMA) ─┐
                                ├→ PPE (Packet Processing Engine) → HW NAT → Switch
Ethernet → GMAC ────────────────┘
```
没有 `mediatek_hnat`：全部流量走 CPU 软件转发，MT7981 1.2GHz 四核单线程 ≈ 25-30 Mbps

### 关键发现
| 项目 | 状态 | 说明 |
|------|------|------|
| `CONFIG_NET_MEDIATEK_HNAT` | ❌ 缺失 | 内核内置驱动编译开关 |
| `kmod-mediatek_hnat` 包 | ❌ 不存在 | 仓库无此包（已移入内核源码） |
| `kmod-warp` DEPENDS | ✅ 依赖 `kmod-mediatek_hnat` | warp 加载时自动拉起 hnat |
| `CONFIG_PACKAGE_kmod-mediatek_hnat=y` | ⚠️ 无效 | 引用不存在的包，OpenWrt 会自动生成 |

## 修改

### 1. `config/X1ProUBoot.config`（第 3719 行新增）
```
CONFIG_NET_MEDIATEK_HNAT=m
```
→ 将 `mtkhnat.ko` 编译为模块，安装到 `/lib/modules/`
→ `kmod-warp` 已 DEPENDS `+kmod-mediatek_hnat`，自动拉起，无需额外配置

### 2. `filogic.mk`（DEVICE_PACKAGES 修正）
```
DEVICE_PACKAGES := kmod-usb3 automount kmod-mt_wifi wifi-dats
```
→ 原 `kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware` 不存在于该仓库
→ `kmod-mt_wifi` 和 `wifi-dats` 已通过 kernel config `CONFIG_PACKAGE_kmod-mt_wifi=y` 编译，
  此处显式声明便于维护

## 预期效果
| 场景 | 修复前 | 修复后 |
|------|--------|--------|
| WiFi 吞吐 | ~25-30 Mbps | ~500-800 Mbps（WiFi6 理论上限内） |
| 有线吞吐 | ~25-30 Mbps | ~2.4 Gbps（MT7981 GMAC） |
| NAT 转发 | CPU 软件转发 | PPE 硬件卸载 |

## 待验证
1. 有线速度（接路由器 LAN 口测iperf3）
2. WiFi 速度（近距离 5GHz）
3. NAT 加速状态：`cat /sys/kernel/debug/hnat/hwnat 2>/dev/null` 或 `mtkhnat` debugfs
4. WED 状态：`cat /sys/kernel/debug/mtk_warp/info`

## 未涉及
- `fullconenat` 软件 NAT：保留，不影响 mtk_hnat 工作（软硬路径并存）
- `kmod-ipt-offload`：`mtk_hnat` 接管 PPE 后自动优先硬件路径
- MAC 地址冲突：见 sum_e98c9669 的待办项
