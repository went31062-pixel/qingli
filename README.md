# UE Freeze Check Skill

面向 Windows 和 Unreal Engine 的快速、只读诊断 skill。它将系统资源、近期事件、指定项目的最新日志整理成一个本地 JSON 摘要，并指导使用 [Libre Hardware Monitor](https://github.com/LibreHardwareMonitor/LibreHardwareMonitor) 核对温度和负载。

## 使用

在仓库目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quick-check.ps1 -ProjectPath 'D:\path\to\project'
```

没有 UE 项目路径时省略 `-ProjectPath`。可用 `-Hours 48` 调整事件窗口。脚本默认只在终端输出，不安装程序、不修改配置、不上传数据。将本目录放入 Codex 的 skills 目录后，也可通过 `$ue-freeze-check` 使用完整流程。

此仓库没有复制 Libre Hardware Monitor 的程序代码。需要温度读数时，请从其官方 GitHub Releases 获取。分析方法和注意事项见 [SKILL.md](SKILL.md)。

