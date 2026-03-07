# Windows Desktop Optimization Tool (WDOT)

## 后期修改

* 自动登录用户密码都是 `m` 的用户
* 禁用注销,锁定,休眠,睡眠
* 禁用windows自动更新
* 关闭 Microsoft Defender 防病毒, 关闭实时保护, 禁用 "打开行为监视", 禁用 "监视计算机上的文件和程序活动"
* 关闭防火墙
* 用户账户控制设置设为“从不”

---

![WDOT](/Images/WDOT_Icon1_Color.png)

> ## Welcome to the next evolution of the Virtual Desktop Optimization Tool

![Static Badge](https://img.shields.io/badge/WDOT_Current_Version-1.0-blue)
![Static Badge](https://img.shields.io/badge/WDOT_Latest_Release-1.0-Green)

![Contributors](https://img.shields.io/github/contributors/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)
![Forks](https://img.shields.io/github/forks/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)
![Stars](https://img.shields.io/github/stars/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)
![Commits](https://img.shields.io/github/last-commit/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)
![Issues](https://img.shields.io/github/issues/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)
![Languages](https://img.shields.io/github/languages/top/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool)

## 📖 Introduction

The **Windows Desktop Optimization Tool (WDOT)** is a comprehensive PowerShell-based solution designed to optimize Windows devices for Virtual Desktop Infrastructure (VDI), Azure Virtual Desktop (AVD), and standalone machines. This tool automates the application of numerous optimization settings to improve performance, reduce resource consumption, and enhance user experience across various Windows environments.

### Key Features

- **🎯 Targeted Optimizations**: Apply specific optimizations for services, applications, scheduled tasks, and system settings
- **🔧 Configuration-Based**: Use customizable JSON configuration files for different environments
- **🛡️ Safe Defaults**: Conservative settings that can be customized per environment
- **📊 Comprehensive Logging**: Built-in Windows Event Log integration for monitoring and troubleshooting
- **🔄 Modular Design**: Choose which optimization categories to apply
- **🎛️ Interactive Configuration**: User-friendly tools for customizing optimization settings

## 🏗️ Architecture

The WDOT consists of three main components:

### 1. Windows_Optimization.ps1 (Main Script)
The primary optimization engine that applies performance and resource optimizations based on configuration profiles.

### 2. Configuration Management Tools
- **New-WVDConfigurationFiles.ps1**: Creates new configuration profiles from templates
- **Set-WVDConfigurations.ps1**: Interactive tool for customizing configuration settings

### 3. Optimization Functions
Modular PowerShell functions in the `Functions/` directory that handle specific optimization categories.

## 🛠️ Installation

### Prerequisites

- **Windows 10/11** or **Windows Server 2019/2022/2025**
- **PowerShell 5.1** or higher
- **Administrator privileges** (required for system-level optimizations)
- **Execution Policy**: Set to allow script execution

### Setup Steps

1. **Clone or Download the Repository**
   ```powershell
   git clone https://github.com/The-Virtual-Desktop-Team/Windows-Desktop-Optimization-Tool.git
   cd Windows-Desktop-Optimization-Tool
   ```

2. **Set PowerShell Execution Policy**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Verify Installation**
   ```powershell
   # Check available configuration profiles
   Get-ChildItem .\Configurations -Directory | Select-Object Name
   ```

## 🎯 Quick Start

### Basic Usage

1. **Create a Configuration Profile**
   ```powershell
   .\New-WVDConfigurationFiles.ps1 -FolderName "MyEnvironment"
   ```

2. **Customize Your Configuration** (Optional)
   ```powershell
   .\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "MyEnvironment"
   ```

3. **Apply Optimizations**
   ```powershell
   .\Windows_Optimization.ps1 -ConfigProfile "MyEnvironment" -Optimizations All -AcceptEULA
   ```

### Example Scenarios

**VDI/AVD Environment:**
```powershell
# Create and configure for VDI
.\New-WVDConfigurationFiles.ps1 -FolderName "Production-VDI"
.\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "Production-VDI" -ApplyAll

# Apply aggressive optimizations
.\Windows_Optimization.ps1 -ConfigProfile "Production-VDI" -Optimizations All -AcceptEULA
```

**Development Workstation:**
```powershell
# Create conservative configuration
.\New-WVDConfigurationFiles.ps1 -FolderName "Development"
.\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "Development" -SkipAll

# Apply selective optimizations
.\Windows_Optimization.ps1 -ConfigProfile "Development" -Optimizations @("DiskCleanup", "NetworkOptimizations") -AcceptEULA
```

## 📊 Windows_Optimization.ps1 - Main Script

The core optimization script that applies various performance and resource optimizations to Windows systems.

### Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `ConfigProfile` | String | **[Required]** Name of configuration profile to use | None |
| `WindowsVersion` | String | **[Being Deprecated]** This parameter is deprecated and will be removed in a future release. Use -ConfigProfile instead. | None |
| `Optimizations` | String[] | Optimization categories to apply | None |
| `AdvancedOptimizations` | String[] | Advanced/aggressive optimizations | None |
| `AcceptEULA` | Switch | Accept EULA without prompting | False |
| `Restart` | Switch | Automatically restart after completion | False |

### Optimization Categories

#### Standard Optimizations (`-Optimizations`)

| Category | Description | Impact |
|----------|-------------|---------|
| `All` | Apply all standard optimizations | High |
| `Services` | Disable unnecessary Windows services | High |
| `AppxPackages` | Remove unwanted Microsoft Store apps | Medium |
| `ScheduledTasks` | Disable unnecessary scheduled tasks | Medium |
| `DefaultUserSettings` | Optimize default user profile settings | Low |
| `LocalPolicy` | Apply local group policy optimizations | Medium |
| `Autologgers` | Disable Windows diagnostic logging | Low |
| `NetworkOptimizations` | Optimize network settings (SMB, etc.) | Medium |
| `DiskCleanup` | Clean temporary files and caches | Low |
| `WindowsMediaPlayer` | Remove Windows Media Player | Low |

#### Advanced Optimizations (`-AdvancedOptimizations`)

| Category | Description | Impact | Warning |
|----------|-------------|---------|---------|
| `All` | Apply all advanced optimizations | High | ⚠️ Aggressive |
| `Edge` | Optimize Microsoft Edge settings | Medium | ⚠️ May affect browsing |
| `RemoveLegacyIE` | Remove Internet Explorer | High | ⚠️ Irreversible |
| `RemoveOneDrive` | Remove OneDrive integration | High | ⚠️ Affects file sync |

### Usage Examples

**Apply All Standard Optimizations:**
```powershell
.\Windows_Optimization.ps1 -ConfigProfile "Windows11_24H2" -Optimizations All -AcceptEULA
```

**Selective Optimization:**
```powershell
.\Windows_Optimization.ps1 -ConfigProfile "MyConfig" -Optimizations @("Services", "AppxPackages", "DiskCleanup") -AcceptEULA
```

**VDI-Focused Optimization:**
```powershell
.\Windows_Optimization.ps1 -ConfigProfile "VDI-Production" -Optimizations @("Services", "AppxPackages", "ScheduledTasks", "NetworkOptimizations") -AdvancedOptimizations @("Edge", "RemoveLegacyIE") -AcceptEULA -Restart
```

**Conservative Optimization:**
```powershell
.\Windows_Optimization.ps1 -ConfigProfile "Conservative" -Optimizations @("DiskCleanup", "NetworkOptimizations") -AcceptEULA
```

## 🔧 Configuration Management

### Creating Configuration Profiles

Use `New-WVDConfigurationFiles.ps1` to create new configuration profiles:

```powershell
.\New-WVDConfigurationFiles.ps1 -FolderName "MyCustomConfig"
```

This creates a new folder in `Configurations/` with template files that can be customized.

### Customizing Configurations

Use `Set-WVDConfigurations.ps1` for interactive configuration:

```powershell
# Interactive configuration
.\Set-WVDConfigurations.ps1 -ConfigurationFile "Services" -ConfigFolderName "MyConfig"

# Apply all optimizations
.\Set-WVDConfigurations.ps1 -ConfigurationFile "AppxPackages" -ConfigFolderName "MyConfig" -ApplyAll

# Skip all optimizations (safe defaults)
.\Set-WVDConfigurations.ps1 -ConfigurationFile "ScheduledTasks" -ConfigFolderName "MyConfig" -SkipAll
```

📖 **For detailed configuration instructions, see: [Configuration Files User Guide](Configuration%20Files%20User%20Guide.md)**

## 📁 Project Structure

```
Windows-Desktop-Optimization-Tool/
├── Windows_Optimization.ps1           # Main optimization script
├── New-WVDConfigurationFiles.ps1      # Configuration profile creator
├── Set-WVDConfigurations.ps1          # Interactive configuration tool
├── EULA.txt                           # End User License Agreement
├── Configuration Files User Guide.md  # Detailed configuration guide
├── Configurations/                    # Configuration profiles
│   ├── Templates/                     # Default template files
│   │   ├── Services.json             # Windows services configuration
│   │   ├── AppxPackages.json         # Store apps configuration
│   │   ├── ScheduledTasks.json       # Scheduled tasks configuration
│   │   ├── DefaultUserSettings.json  # User profile settings
│   │   ├── PolicyRegSettings.json    # Group policy settings
│   │   ├── EdgeSettings.json         # Microsoft Edge settings
│   │   ├── Autologgers.Json          # Diagnostic logging settings
│   │   ├── LanManWorkstation.json    # Network optimization settings
│   │   └── DefaultAssociationsConfiguration.xml # File associations
│   └── [Custom Profiles]/            # User-created configuration profiles
├── Functions/                         # Optimization function modules
└── Images/                           # Project icons and images
```

## 📋 Configuration Files

Each configuration profile contains JSON files that control optimization behavior:

### Configuration File Types

| File | Purpose | Items | OptimizationState Values |
|------|---------|-------|---------------------------|
| `Services.json` | Windows services to disable/enable | ~45 services | `Apply` / `Skip` |
| `AppxPackages.json` | Store apps to remove/keep | ~80 packages | `Apply` / `Skip` |
| `ScheduledTasks.json` | Scheduled tasks to disable | ~30 tasks | `Apply` / `Skip` |
| `DefaultUserSettings.json` | User profile registry settings | ~20 settings | `Apply` / `Skip` |
| `PolicyRegSettings.json` | Local policy registry settings | ~15 policies | `Apply` / `Skip` |
| `EdgeSettings.json` | Microsoft Edge optimizations | ~10 settings | `Apply` / `Skip` |
| `Autologgers.Json` | Diagnostic logging services | ~15 loggers | `Apply` / `Skip` |
| `LanManWorkstation.json` | Network performance settings | ~5 settings | `Apply` / `Skip` |

### OptimizationState Values

- **`Apply`**: The optimization will be applied during execution
- **`Skip`**: The optimization will be ignored (safe/conservative choice)

## 🔍 Monitoring and Logging

WDOT includes comprehensive logging capabilities:

### Windows Event Log Integration

- **Log Name**: `WDOT`
- **Event Sources**: Multiple sources for different optimization categories
- **Event Types**: Information, Warning, Error
- **Log Size**: 64KB with automatic rotation

### Viewing WDOT Logs

```powershell
# View recent WDOT events
Get-WinEvent -LogName "WDOT" -MaxEvents 50

# View specific optimization results
Get-WinEvent -LogName "WDOT" | Where-Object {$_.Id -eq 1}
```

### Registry Tracking

WDOT maintains execution tracking in the registry:

- **Location**: `HKLM:\SOFTWARE\WDOT`
- **Values**: Version, LastRunTime
- **Purpose**: Track optimization history and version compatibility

## ⚠️ Important Considerations

### Testing Requirements

> **⚠️ WARNING**: These optimizations modify system behavior. Always test in a non-production environment first.

### Environment Suitability

- **VDI/AVD**: All optimizations suitable with proper testing
- **Physical Workstations**: Use conservative settings, avoid hardware-specific optimizations
- **Server Environments**: Carefully review service and application optimizations
- **Development Machines**: Use minimal optimizations to preserve development tools

### Backup Recommendations

1. **System Restore Point**: Create before running optimizations
2. **Registry Backup**: Export relevant registry keys
3. **Configuration Backup**: Use `-CreateBackup` flag with `Set-WVDConfigurations.ps1`

## 🤝 Contributing

We welcome contributions to improve WDOT:

1. **Fork** the repository
2. **Create** a feature branch
3. **Test** your changes thoroughly
4. **Submit** a pull request with detailed description

### Development Guidelines

- Follow PowerShell best practices
- Include proper error handling
- Add verbose logging for troubleshooting
- Test on multiple Windows versions
- Document new optimization categories

## 📄 License

This project is provided under the Microsoft Sample Code License. See [EULA.txt](EULA.txt) for complete terms.

**Key Points:**
- Provided "AS IS" for illustration purposes
- Not intended for production without testing
- No warranty or support guarantees
- User assumes all risks and responsibilities

## 🆘 Support

### Getting Help

1. **Check the Documentation**: Review this README and the Configuration Files User Guide
2. **Review Event Logs**: Check the WDOT Windows Event Log for detailed error information
3. **GitHub Issues**: Search existing issues or create a new one
4. **Community Support**: Engage with the community through GitHub Discussions

### Troubleshooting

**Common Issues:**

- **Execution Policy**: Ensure PowerShell execution policy allows script execution
- **Permissions**: Run PowerShell as Administrator
- **Configuration Not Found**: Verify configuration profile exists in `Configurations/` folder
- **Service Dependencies**: Some services may have dependencies that prevent disabling

### Useful Commands

```powershell
# Check execution policy
Get-ExecutionPolicy

# View available configurations
Get-ChildItem .\Configurations -Directory

# Test configuration file validity
if ($PSVersionTable.PSVersion -gt [version]'6.0.0') {
 Test-Json -Path ".\Configurations\MyConfig\Services.json"
}
# Check WDOT version and last run
Get-ItemProperty "HKLM:\SOFTWARE\WDOT"
```

---

**Authors**: Robert M. Smith and Tim Muessig (Microsoft)  
**Project**: Windows Desktop Optimization Tool  
**Last Updated**: October 2025
