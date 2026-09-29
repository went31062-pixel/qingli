---
name: ue-freeze-check
description: 快速排查 Windows 电脑卡顿、Unreal Engine 编辑器无响应或崩溃；结合只读系统快照、UE 日志及硬件温度判断下一步。
---

# UE 卡顿与死机速查

适用于 Windows 上的 UE 编辑器卡顿、崩溃，以及整机短暂无响应。先取得证据，再根据证据决定是否需要深入分析；不要把一次高温、单条事件或普通 UE Warning 当成根因。

## 快速检查

1. 先确认故障范围：只有 UE 退出、UE 窗口无响应，还是整台电脑都不能操作；记录发生时间、UE 版本、触发动作和是否能稳定复现。
2. 在本 skill 目录运行只读脚本：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quick-check.ps1 -ProjectPath 'D:\path\to\project'
   ```

   不知道项目目录时省略 `-ProjectPath`。脚本只读取内存、磁盘、进程、近期 Windows 事件和指定项目的最新日志；默认只向终端输出 JSON，不写磁盘、不联网、不修改系统。
3. 若怀疑过热、降频或硬件负载异常，从 [Libre Hardware Monitor 官方 GitHub Release](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/releases) 下载，运行图形程序。让它在 UE 复现期间显示 CPU/GPU 温度、频率、负载和风扇转速，记录空闲与卡顿时的数值。不要从同名第三方网站下载。部分传感器需要管理员权限，读数缺失或异常时先核对设备厂商工具。
4. 对照故障时间看项目 `Saved/Logs` 的错误和 Windows 事件。将 `GPU crashed`、`out of video memory`、`EXCEPTION_ACCESS_VIOLATION` 等视为线索，并结合堆栈、驱动事件、资源占用确认。
5. 如果整机资源正常而 UE 操作持续慢，先用 UE 自带的 `stat unit` / `stat gpu` 看瓶颈，再按需要使用 Unreal Insights 采样。不要在已经卡到难以操作的机器上默认开启长时间完整追踪。

## 判断与交付

- 区分“已观察到的事实”“可能原因”“下一步验证”。给出最少的下一步，优先可逆操作。
- 日志没有明确错误时说明证据不足，不用经验猜测替代证据。
- 分享日志或 JSON 前检查项目路径、用户名、机器名、插件信息等私人内容；未经用户同意，不上传完整诊断包或崩溃转储。
- 不自动修改注册表、驱动、UE 配置、缓存或超频设置；修复动作按实际证据提出。

## 依据

- [Libre Hardware Monitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor)：开源硬件传感器监控，MPL 2.0。
- [Epic：UE 日志](https://dev.epicgames.com/documentation/unreal-engine/logging-in-unreal-engine)：项目日志位于 `Saved/Logs`。
- [Epic：UE 性能分析](https://dev.epicgames.com/documentation/unreal-engine/introduction-to-performance-profiling-and-configuration-in-unreal-engine)：`stat` 命令与 Unreal Insights 的用途。
- [Microsoft：Windows 卡死排查](https://learn.microsoft.com/en-us/troubleshoot/windows-client/performance/windows-based-computer-freeze-troubleshooting)：事件日志及系统诊断。

