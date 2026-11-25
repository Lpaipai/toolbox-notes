# 16K60 工作站初始化与点屏配置

适用参考环境：Lenovo ThinkStation PX、双 NVIDIA RTX PRO 6000、Quadro Sync II / RTX PRO Sync、Windows、8 路 DP 横向 Mosaic（15360 × 7680 @ 60 Hz，每路 1920 × 7680 @ 60 Hz）。

## 一、进入 BIOS

开机时连续按 **F1** 进入 BIOS；F12 为启动菜单，F10 保存并退出，F9 恢复默认设置（不要无故恢复默认）。

重点检查 Devices → Video Setup、Devices → PCI Express Setup。不同 BIOS 版本的选项名称可能不同。

| 选项 | 配置建议 |
|---|---|
| Above 4G Decoding | Enabled，重点检查多显卡地址空间分配 |
| Re-Size BAR | 保持默认；如遇异常，可沿用历史排查配置 Disabled |
| PCIe ASPM | Disabled，作为稳定性排查配置 |
| SR-IOV | 无虚拟化需求可关闭 |
| PCIe Bifurcation | 对实际安装显卡的 x16 插槽保持完整通道；旧机曾检查 Slot 6 / Slot 8 |
| PCIe Link Speed | Auto 优先；异常时尝试固定 Gen4 / Gen3 |
| Primary Display | Auto 或实际用于操作屏的 GPU，视接线而定 |

先记录原设置，再按需修改。Gen3、关闭 Re-Size BAR 等属于历史排查手段，不是 Mosaic 的必要条件。PCIe 速率与 DP HBR3 链路速率是不同概念。

## 二、Windows 初始化

1. 安装 Lenovo 对应机型的必要芯片组驱动及旧机已经验证稳定的 NVIDIA RTX Enterprise Driver。
2. 在 CMD 中确认两张显卡均被识别：

```cmd
nvidia-smi
nvidia-smi --query-gpu=index,name,driver_version,memory.total,ecc.mode.current --format=csv
```

3. 建议用于长期点屏的系统设置：

| 项目 | 建议 |
|---|---|
| 电源计划 | 高性能 / 最佳性能 |
| 自动睡眠、自动关闭屏幕 | 从不 |
| 快速启动 | 关闭，便于完整启动测试 |
| PCI Express 链接状态电源管理 | 关闭 |
| HDR / VRR | 初次测试关闭 |
| 显示缩放 | 100% |
| 显示模式 | 扩展 |

## 三、NVIDIA 控制面板

- 管理 3D 设置 → 电源管理模式 → 最高性能优先（点屏测试配置）。
- 设置 SLI 和 PhysX（或配置多 GPU 相关菜单）→ **激活所有显示器（Activate all displays）**，若该选项可用。不要误选用于计算或渲染的模式。
- 设置多个显示器 → 勾选全部目标输出。
- 更改 ECC 状态 → 如旧机采用关闭 ECC 的配置且不需要 ECC，按需关闭两张 GPU 的 ECC；重启并检查生效情况。这不是 Mosaic 的硬性要求。
- 更改分辨率 → 每路 1920 × 7680 @ 60 Hz；按接收端支持的 timing、EDID 和带宽设置。
- 初次测试使用 8 bpc、RGB、完全动态范围（接收端需匹配）。
- 查看系统拓扑 → 确认显卡、显示器及同步卡连接情况。

### 重要经验：激活所有显示器

历史排查中曾出现 GPU 已检测到接收端，但未立即输出视频，造成接收端无法获得 Video Lock、反复复位。选择 Activate all displays 后重启，曾成功完成八路连接；仍需重复测试，不能视为彻底消除连接异常。

HPD 有效只表示接收端连接信号有效，并不等于完成 Link Training 或已有有效视频输出。

## 四、同步卡检查

- 核对同步卡型号及 GPU 同步线连接（检查硬件前先关机断电）。
- 在 NVIDIA 控制面板的系统拓扑与同步显示器页面检查识别和同步状态。
- [NVIDIA RTX PRO Sync 固件下载页](https://www.nvidia.cn/drivers/firmware/rtx-pro-sync-firmware-driver/)（历史记录版本 3.06；按实际型号和兼容性确认）。

仅在确有需要且固件包说明确认支持当前硬件时升级。旧记录中的 NVSyncUpdate.exe status / install 命令需先以实际下载包的 README 或 help 核实，不直接盲刷。按厂商要求重启或断电重启后检查固件与同步状态。

## 五、Mosaic 拼接

1. 先分别验证两张 GPU 的独立视频输出。
2. 接入全部八路 DP，核对 HPD、Link Training、Video Lock 和通道顺序；目标 DP 链路为 HBR3（8.1 Gbps/lane）。
3. NVIDIA 控制面板 → 工作站 → 设置 Mosaic。
4. 选择 1 行 × 8 列，单路 1920 × 7680 @ 60 Hz，重叠为 0；逻辑桌面 15360 × 7680 @ 60 Hz。
5. 核对画面排列、刷新率及实际跨 GPU Frame Lock 同步状态；仅 Mosaic 成功不等于同步已经锁定。

## 六、导出与恢复 Mosaic

完整教程及脚本：[NVIDIA Mosaic Utility / configureMosaic](nvidia-mosaic/README.md)。

首次正确拼接后，在管理员 CMD 中执行（替换为实际目录）：

```cmd
cd /d "D:\Tools\NVIDIA-Mosaic"
configureMosaic.exe listconfigcmd > restore.bat
```

确认导出的 BAT 是有效重建命令；若工具不支持该命令，查阅对应版本帮助及上述教程。恢复时在全部目标显示器连接且端口映射匹配的前提下，以管理员身份执行 restore.bat。新机器建议重新导出，不直接复用旧机的 GPU / DP 映射。

## 七、验收 Checklist

- [ ] BIOS Above 4G Decoding 与实际 GPU 插槽配置检查
- [ ] 安装已验证驱动，nvidia-smi 识别双 GPU
- [ ] 关闭长期点屏不需要的节能功能
- [ ] Activate all displays（若适用）
- [ ] 检查 ECC 配置及同步卡识别
- [ ] 两张 GPU 独立输出正常
- [ ] 八路 DP HPD、Link Training、Video Lock 正常
- [ ] 1 × 8 Mosaic，15360 × 7680 @ 60 Hz
- [ ] 跨 GPU Frame Lock 同步正常
- [ ] 导出并验证 restore.bat
- [ ] 多次重启、冷启动、重新连接及长时间稳定性测试

## 八、机器配置记录模板

| 项目 | 实测值 |
|---|---|
| BIOS 版本 / 实际配置 | 待记录 |
| GPU 型号 / PCIe 插槽 | 待记录 |
| NVIDIA 驱动版本 | 待记录 |
| Sync 卡型号 / 固件版本 | 待记录 |
| configureMosaic 版本 | 待记录 |
| DP 端口映射 / timing | 本地保存 |
| 冷启动及长时间测试结果 | 待记录 |

## 更新记录

- 2026-11-25：整理新工作站初始化、BIOS、Windows、双 GPU、Sync、Mosaic 与恢复脚本流程。历史最终 BIOS 参数、驱动版本尚未完整确认，建议新机验证后补齐。本文为通用点屏备忘录，不包含内部工程信息。
