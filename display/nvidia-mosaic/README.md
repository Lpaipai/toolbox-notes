# NVIDIA Mosaic Utility（configureMosaic）

通过 NVIDIA 官方命令行工具读取当前 Mosaic 拓扑，并把恢复命令导出为 BAT 文件。以后需要恢复拼屏时，直接以管理员权限运行导出的 BAT，不必重新手工填写 8 个显示器的 GPU / DP 输出映射。

## 基本信息

| 项目 | 信息 |
|---|---|
| 工具 | NVIDIA Mosaic Utility |
| 核心程序 | `configureMosaic.exe` |
| 当前官方页面版本 | **2.5.3** |
| 官方页面发布日期 | 2026-07-13 |
| 支持系统 | Windows 10 / Windows 11 |
| 官方下载页 | [NVIDIA Mosaic Utility](https://www.nvidia.com/en-us/drivers/mosaic-utility/) |
| 官方程序直链 | [configureMosaic.exe 2.5.3](https://us.download.nvidia.com/Windows/Quadro_Certified/Mosaic-Utility/2.5.3/configureMosaic.exe) |
| 官方命令说明 | [readme.txt](https://us.download.nvidia.com/Windows/Quadro_Certified/Mosaic-Utility/2.5.3/readme.txt) |
| NVIDIA 用户指南 | [Mosaic Technology User's Guide (PDF)](https://images.nvidia.cn/aem-dam/en-zz/Solutions/design-visualization/quadro-product-literature/NVMosaic-UG.pdf) |

> 版本说明：之前使用记录为 2.4.9；本条目按 2026-11-23 查询到的 NVIDIA 官方下载页面记录 2.5.3。升级前应以目标工作站的驱动、显卡和实际兼容性为准。

## 使用环境记录

以下是这套备忘录对应的实际工作场景，不代表所有机器都必须采用相同配置：

- 工作站：ThinkStation PX
- 显卡：双 NVIDIA RTX PRO 6000
- 同步卡：Quadro Sync II
- 显示目标：8 屏横向 Mosaic
- 目标逻辑桌面：15360 × 7680

## 一、下载与准备

1. 打开 [NVIDIA Mosaic Utility 官方下载页](https://www.nvidia.com/en-us/drivers/mosaic-utility/)。
2. 下载 Mosaic Utility。当前官方页面列出的版本为 2.5.3。
3. 将 `configureMosaic.exe` 放在一个固定目录，例如：

   ```text
   D:\\Tools\\NVIDIA-Mosaic\\
   ├── configureMosaic.exe
   ├── export-config.bat
   ├── run-restore.bat
   └── restore.bat             # 导出后生成，机器专属
   ```

4. 本仓库的脚本位于 `scripts/`。将脚本复制到上面这个工具目录，或按脚本注释调整工具目录位置。
5. 运行配置变更命令需要管理员权限。建议使用“以管理员身份运行”的 CMD。

## 二、先完成一次正确的 Mosaic 拼屏

首次配置或需要改变拓扑时，先在 NVIDIA 控制面板中完成 Mosaic 设置，确认屏幕数量、排列顺序、分辨率、刷新率、GPU 和 DP 物理输出映射均正确。

确认拼屏工作正常后，再导出配置。不要在拓扑尚未正确时导出，否则保存下来的就是错误配置。

## 三、导出配置为 BAT（最重要）

### 方法 A：直接执行命令

在管理员 CMD 中切换到 `configureMosaic.exe` 所在目录：

```cmd
cd /d "D:\\Tools\\NVIDIA-Mosaic"
configureMosaic.exe listconfigcmd > restore.bat
```

执行后，当前目录会生成 `restore.bat`。其中保存的是工具根据**当前已生效 Mosaic 拓扑**生成的重建命令。

### 方法 B：使用仓库中的导出脚本

将 [export-config.bat](scripts/export-config.bat) 复制到 `configureMosaic.exe` 同一目录，管理员身份运行。脚本会执行同一条 `listconfigcmd` 命令，并在工具目录生成 `restore.bat`。

> 建议使用 CMD 执行直接导出命令。这样生成 BAT 时采用 CMD 的重定向行为，避免 Windows PowerShell 5.1 对文本重定向可能采用 UTF-16 编码而造成的批处理兼容问题。

## 四、恢复 Mosaic

确认所有属于该 Mosaic 拓扑的显示器均已连接，随后：

1. 以管理员身份打开 CMD。
2. 切换到 `restore.bat` 所在目录。
3. 执行：

   ```cmd
   restore.bat
   ```

也可以将 [run-restore.bat](scripts/run-restore.bat) 复制到工具目录，管理员身份运行它。该脚本会切换到自身所在目录，再调用 `restore.bat`。

恢复过程可能导致显示器闪烁或显示链路重新初始化。执行前保存工作，并关闭不希望因显示驱动重置而中断的应用。

## 五、常用命令速查

在 `configureMosaic.exe` 所在目录、管理员 CMD 中执行：

| 命令 | 用途 |
|---|---|
| `configureMosaic.exe help` | 查看命令帮助 |
| `configureMosaic.exe query all` | 查询 GPU、显示器和当前拓扑 |
| `configureMosaic.exe listconfigcmd` | 输出重建当前 Mosaic 拓扑所需的命令 |
| `configureMosaic.exe listconfigcmd > restore.bat` | 将当前拓扑导出为 BAT |

其中，**日常备份只需要记住最后一条命令**。

## 六、注意事项

- `restore.bat` 是与当前工作站的显卡、GPU 编号、物理输出端口和屏幕拓扑绑定的配置文件。换机器或更换 DP 接线后，应重新配置并导出，不要假设旧 BAT 仍然适用。
- 不要把真实的 `restore.bat` 当作通用示例提交到公共仓库。本仓库的 `.gitignore` 已忽略该文件；需要长期保存时，建议放在自己的私有备份位置。
- NVIDIA 用户指南说明：热插拔后，只有当原 Mosaic 拓扑中的所有显示器都重新连接时，Mosaic 才会恢复。只接回部分屏幕时，不应期待完整拓扑自动恢复。
- NVIDIA 官方 2.5.3 页面列出了 RTX PRO 6000 Blackwell Workstation Edition 和 Quadro Sync II 支持信息；具体工作站仍应以实际驱动和硬件组合验证结果为准。
- 2.5.3 更新说明提到 `configureMosaic` 的 `display` 参数已弃用。使用 `listconfigcmd` 导出的机器配置时，不要自行批量替换或删改参数；如升级工具后恢复失败，重新执行 `help` 并检查新版本官方 readme。

## 七、参考资料

1. [NVIDIA Mosaic Utility 下载页](https://www.nvidia.com/en-us/drivers/mosaic-utility/)
2. [NVIDIA configureMosaic 2.5.3 readme](https://us.download.nvidia.com/Windows/Quadro_Certified/Mosaic-Utility/2.5.3/readme.txt)
3. [NVIDIA Mosaic Technology User's Guide](https://images.nvidia.cn/aem-dam/en-zz/Solutions/design-visualization/quadro-product-literature/NVMosaic-UG.pdf)
4. [NVIDIA Developer Forum：listconfigcmd 可输出重建当前 display wall 的命令](https://forums.developer.nvidia.com/t/remote-access-to-a-mosaic-display/112557)

## 更新记录

- 2026-11-23：建立首版；记录官方 2.5.3 下载入口、当前拓扑导出命令和 BAT 恢复流程。
