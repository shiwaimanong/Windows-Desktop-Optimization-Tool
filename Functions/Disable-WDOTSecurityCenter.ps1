function Disable-WDOTSecurityCenter
{
    [CmdletBinding()]
    Param
    (
        
    )

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
        Write-Host "Disabling Windows Security Center, Defender, and Firewall..." -ForegroundColor Magenta

        # Check for Tamper Protection
        $TamperProtectionState = $false
        if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
            $Status = Get-MpComputerStatus -ErrorAction SilentlyContinue
            if ($Status -and $Status.IsTamperProtected -eq $true) {
                $TamperProtectionState = $true
                Write-Warning "Tamper Protection is ENABLED. Many settings may not stick or will be reverted automatically."
                Write-Warning "Please MANUALLY disable 'Tamper Protection' in Windows Security -> Virus & threat protection settings."
            }
        }
    }

    Process
    {
        # --- 1. Disable Windows Firewall ---
        Write-Verbose "Disabling Windows Firewall Profiles (Domain, Public, Private)..."
        if (Get-Command Set-NetFirewallProfile -ErrorAction SilentlyContinue) {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction SilentlyContinue
        }
        
        # Stop Firewall Service (MPSvc) if possible (often protected but worth a try)
        if (Get-Service "mpssvc" -ErrorAction SilentlyContinue) {
            Set-Service -Name "mpssvc" -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name "mpssvc" -Force -ErrorAction SilentlyContinue
        }

        # --- 2. Disable Windows Defender Real-Time Protection & Cloud Protection ---
        if (Get-Command Set-MpPreference -ErrorAction SilentlyContinue) {
            Write-Verbose "Disabling Defender features via Set-MpPreference"
            # Real-time protection
            Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
            
            # Cloud protection & automatic sample submission
            Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue # Disable Cloud Protection
            Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue # Never send samples

            # Other protections
            Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisablePrivacyMode $true -ErrorAction SilentlyContinue
            Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableArchiveScanning $true -ErrorAction SilentlyContinue
            Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction SilentlyContinue
            
            # Network Protection
            Set-MpPreference -EnableNetworkProtection Disabled -ErrorAction SilentlyContinue
            
            # Controlled Folder Access
            Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue
        }

        # --- 3. Disable Defender via Registry (Policies) ---
        $PoliciesPaths = @(
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet"
        )

        foreach ($Path in $PoliciesPaths) {
            if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        }

        # Disable AntiSpyware
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        
        # Disable Real-Time Protection
        $RealTimePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
        Set-ItemProperty -Path $RealTimePath -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $RealTimePath -Name "DisableOnAccessProtection" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $RealTimePath -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $RealTimePath -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        # Disable SpyNet (Cloud)
        $SpyNetPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet"
        Set-ItemProperty -Path $SpyNetPath -Name "SpynetReporting" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $SpyNetPath -Name "SubmitSamplesConsent" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

        # --- 4. Disable Security Center Notifications & Tray Icon ---
        $SecCenterNotifPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications"
        if (-not (Test-Path $SecCenterNotifPath)) { New-Item -Path $SecCenterNotifPath -Force | Out-Null }
        Set-ItemProperty -Path $SecCenterNotifPath -Name "DisableNotifications" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $SecCenterNotifPath -Name "DisableEnhancedNotifications" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        $SystrayPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray"
        if (-not (Test-Path $SystrayPath)) { New-Item -Path $SystrayPath -Force | Out-Null }
        Set-ItemProperty -Path $SystrayPath -Name "HideSystray" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        # --- 5. Disable SmartScreen ---
        Write-Verbose "Disabling SmartScreen..."
        $SmartScreenPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        )
        foreach ($Path in $SmartScreenPaths) {
            if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        # --- 6. Set UAC to Never Notify ---
        Write-Verbose "Disabling UAC..."
        $UACPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        if (Test-Path $UACPath) {
            Set-ItemProperty -Path $UACPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $UACPath -Name "PromptOnSecureDesktop" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }

        # --- 7. Disable Security Services (Attempt via Registry) ---
        # Note: These services are protected and difficult to disable directly.
        # We try to set Start type to Disabled (4) via registry.
        
        $ServicesToDisable = @(
            "SecurityHealthService", # Security Center Service
            "wscsvc",                # Windows Security Center Service
            "WinDefend",             # Microsoft Defender Antivirus Service
            "Sense",                 # Windows Defender Advanced Threat Protection Service
            "WdBoot",                # Microsoft Defender Antivirus Boot Driver
            "WdFilter",              # Microsoft Defender Antivirus Mini-Filter Driver
            "WdNisDrv",              # Microsoft Defender Antivirus Network Inspection System Driver
            "WdNisSvc"               # Microsoft Defender Antivirus Network Inspection Service
        )

        foreach ($Service in $ServicesToDisable) {
            $ServiceRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$Service"
            if (Test-Path $ServiceRegPath) {
                Write-Verbose "Setting start type of $Service to Disabled"
                Set-ItemProperty -Path $ServiceRegPath -Name "Start" -Value 4 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host "Windows Security Center, Defender, Firewall, and UAC have been configured to be disabled." -ForegroundColor Green
        if ($TamperProtectionState -eq $true) {
            Write-Host "IMPORTANT: Tamper Protection was detected as ENABLED. You must manually disable it for these changes to persist!" -ForegroundColor Red -BackgroundColor Yellow
        }
    }
}
