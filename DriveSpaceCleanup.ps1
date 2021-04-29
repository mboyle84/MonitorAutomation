#written by: Mike 2021 April 27
#
#error handling and logging
#Set-StrictMode -Version latest
$Error.clear()
$Error
$ErrorActionPreference = "Stop"
$RecycleBinPath0 = 'C:\$Recycle.bin'
$RecycleBinPath1 = $env:systemdrive + '\$Recycle.bin'
$RecycleBinPath2 = 'C:\$Recycle.bin'
$RecycleBinPath2 = 'D:\$Recycle.bin'
$RecycleBinPath3 = 'E:\$Recycle.bin'
$RecycleBinPath4 = 'F:\$Recycle.bin'
$TempPath1= “C:\Windows\Temp”
$TempPath2= “C:\Windows\Prefetch”
$TempPath3= “C:\Documents and Settings\*\Local Settings\temp”
$TempPath4= “C:\Windows\Temp”
$TempPath5= “C:\Users\*\Appdata\Local\Temp”
$TempPath6= “C:\Temp”
$WindowsOld= “C:\Windows.old”
$RecycleBinPaths = @($RecycleBinPath0, $RecycleBinPath1, $RecycleBinPath2, $RecycleBinPath3, $RecycleBinPath4)
$TempPaths = @($TempPath1, $TempPath2, $TempPath3, $TempPath4, $TempPath5, $TempPath6)
$TempRetention = 30
$InetPubRetention = 1825
$InetpubLogPath= "C:\inetpub\logs\LogFiles"
$Filter= "d"


function timestamp() {
    return ("$(Get-Date) >")
}

try
{
Write-Host "$(timestamp) [INFO] Beginning of drive/volume space cleaning script"
Write-Host "$(timestamp) [INFO] Remove attempt of $RecycleBinPaths $WindowsOld"
foreach ($RecycleBinPath in $RecycleBinPaths)
	{
		If (Test-Path $RecycleBinPath)
			{
				Write-Host "$(timestamp) [INFO] path exists $RecycleBinPath"	
				Remove-Item $RecycleBinPath -Recurse -Force -ErrorAction SilentlyContinue
				Write-Host "$(timestamp) [INFO] path removed $RecycleBinPath"	
			}
			ELSE
			{
				Write-Host "$(timestamp) [INFO] path does not exist $RecycleBinPath"
			}	
	}

Write-Host "$(timestamp) [INFO] Remove attempt of  $WindowsOld" 
If (Test-Path $WindowsOld)
			{
				Write-Host "$(timestamp) [INFO] path exists $WindowsOld"	
				Remove-Item $WindowsOld -Recurse -Force -ErrorAction SilentlyContinue
			}
			ELSE
			{
				Write-Host "$(timestamp) [INFO] path does not exist $WindowsOld"
			}
}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered removing $RecycleBinPaths $WindowsOld" -ForegroundColor Red
    Write-Error $_
}
try
{
    Write-Host "$(timestamp) [INFO] Looking for file(s) older then $TempRetention days in $TempPaths..."
	foreach ($TempPath in $TempPaths)
	{
		If (Test-Path $TempPath)
			{
				Write-Host "$(timestamp) [INFO] path exists $TempPath"	
				Write-Host "$(timestamp) [INFO] searching for files to remove"	
				
				foreach ($i in Get-ChildItem -Path $TempPath -Recurse)
				{
					if ($i.LastWriteTime -lt (Get-Date).AddDays(-$TempRetention) -And $i.mode -notmatch $Filter)
					{
						Write-Host "$(timestamp) [INFO] attemp removal of $i"
						Remove-Item -Path $i.FullName -Force -ErrorAction SilentlyContinue
						#Write-Host "$(timestamp) [INFO] Removed of $TempPath directory with last date $i.LastWriteTime"
					}
					ELSE
					{
						#Write-Host "$(timestamp) [INFO] Can't Removed $i "
					}
				}
			}
			ELSE
			{
				Write-Host "$(timestamp) [INFO] path does not exist $TempPath"
			}	
	}	
}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered removing $TempRetention days in $TempPaths" -ForegroundColor Red
    Write-Error $_
}



Write-Host "$(timestamp) [INFO] Ended script successfully"

