function Optimize-WDOTPowerSettings {
    [CmdletBinding()]
    Param ()

    Begin {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
    }

    Process {
        try {
            # Set Power Plan to High Performance
            Write-EventLog -EventId 110 -Message "Setting Power Plan to High Performance" -LogName 'WDOT' -Source 'PowerSettings' -EntryType Information
            Write-Verbose "Setting Power Plan to High Performance"
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

            # Set Monitor Timeout to Never (0)
            Write-EventLog -EventId 110 -Message "Setting Monitor Timeout to Never" -LogName 'WDOT' -Source 'PowerSettings' -EntryType Information
            Write-Verbose "Setting Monitor Timeout to Never"
            powercfg /change monitor-timeout-ac 0
            powercfg /change monitor-timeout-dc 0

            # Set Standby Timeout to Never (0)
            Write-EventLog -EventId 110 -Message "Setting Standby Timeout to Never" -LogName 'WDOT' -Source 'PowerSettings' -EntryType Information
            Write-Verbose "Setting Standby Timeout to Never"
            powercfg /change standby-timeout-ac 0
            powercfg /change standby-timeout-dc 0

            # Set Hibernate Timeout to Never (0) - just in case
            Write-EventLog -EventId 110 -Message "Setting Hibernate Timeout to Never" -LogName 'WDOT' -Source 'PowerSettings' -EntryType Information
            Write-Verbose "Setting Hibernate Timeout to Never"
            powercfg /change hibernate-timeout-ac 0
            powercfg /change hibernate-timeout-dc 0
            
        }
        catch {
            Write-Error "Error in Optimize-WDOTPowerSettings: $_"
            Write-EventLog -EventId 110 -Message "Error in Optimize-WDOTPowerSettings: $_" -LogName 'WDOT' -Source 'PowerSettings' -EntryType Error
        }
    }
}
