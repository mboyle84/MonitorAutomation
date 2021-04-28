#written by: Mike B 2021 April 27
#Contact: 
#
#error handling and logging
#Set-StrictMode -Version latest
$Error.clear()
$Error
$ErrorActionPreference = "Stop"
$RecycleBinPath1 = $env:systemdrive + '\$Recycle.bin'
$RecycleBinPath2 = 'D:\$Recycle.bin'
$TempPath1= “C:\Windows\Temp\*”
$TempPath2= “C:\Windows\Prefetch\*”
$TempPath3= “C:\Documents and Settings\*\Local Settings\temp\*”
$TempPath4= “C:\Windows\Temp\*”
$TempPath5= “C:\Users\*\Appdata\Local\Temp\*”
$TempPath6= “C:\Windows.old\*”
$tempfolders = @($RecycleBinPath1, $RecycleBinPath2, $TempPath1, $TempPath2, $TempPath3, $TempPath4, $TempPath5, $TempPath6)

function timestamp() {
    return ("$(Get-Date) >")
}
try
{
Write-Host "$(timestamp) [INFO] Beginning of drive cleaning script"
Write-Host "$(timestamp) [INFO] Attempting to remove RecycleBin with powershell" 
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "$(timestamp) [INFO] Empty various recylcing and temp Folders $tempfolders" 
Remove-Item $tempfolders -Recurse -Force -ErrorAction SilentlyContinue  
}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered processing sessions" -ForegroundColor Red
    Write-Error $_
    exit 1
}
Write-Host "$(timestamp) [INFO] Ended script successfully"

