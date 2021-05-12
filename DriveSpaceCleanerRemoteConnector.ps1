#written by: Mike
#
#error handling and logging
#Set-StrictMode -Version latest
$Error.clear()
$Error
$ErrorActionPreference = "Stop"
$Logfile = "D:\Scripts\Logs\DriveCleanupConnectionLog.txt"
$LocalHost = $env:computername
$IPAddress = $args[0]
$SystemName = $args[1]
$DisplayName = $args[2]
$script = "D:\Scripts\DriveSpaceCleanerRemote.ps1"

#$SystemName = "conrch1wppfil03"

function timestamp() {
    return ("$(Get-Date) >")
}

try
{
Write-output "$(timestamp) [INFO] Beginning of connection script" >> $Logfile
Write-output "$(timestamp) [INFO] attempt to run commands on host $SystemName" >> $Logfile
whoami >> $Logfile
    if ( [bool](Test-WSMan -ComputerName $SystemName -ErrorAction SilentlyContinue) ) {
        Write-output "$(timestamp) [INFO] Test WSMan success to $SystemName attempt commands" >> $Logfile
        if ( [bool](Invoke-Command -ComputerName $SystemName -ScriptBlock {"hello from $env:computername"} -ErrorAction SilentlyContinue) ) {
            Write-output "$(timestamp) [INFO] Test commands success to $SystemName" >> $Logfile
            Write-output "$(timestamp) [INFO] running remote script $script on "$SystemName >> $Logfile
            Invoke-Command -ComputerName $SystemName -FilePath $script >> $Logfile
        }
        Else
        {
        Write-output "$(timestamp) [ERROR] Test commands failed to $SystemName" >> $Logfile
        Exit 1
        }
    }
    Else
    {
    Write-output "$(timestamp) [ERROR] Test WSMan failed to $SystemName attempt commands" >> $Logfile
    Exit 1
    }
}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered during connect" >> $Logfile
    Write-output $_ >> $Logfile
}
Write-output "$(timestamp) [INFO] connection Script complete" >> $Logfile
