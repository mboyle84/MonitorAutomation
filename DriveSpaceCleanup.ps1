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
$InetPubRetention = 6
$InetpubLogPath1= "C:\inetpub\logs\LogFiles"
$InetpubLogPath2= "D:\inetpub\logs\LogFiles"
$InetpubLogPath3= "E:\inetpub\logs\LogFiles"
$InetpubLogPath4= "F:\inetpub\logs\LogFiles"
$InetpubLogPaths = @($InetpubLogPath1, $InetpubLogPath2, $InetpubLogPath3, $InetpubLogPath4)
$InetpubYear = 0
$Filter= "d"
$FolderSize = 0
$ZipFolder = ""

function timestamp() {
    return ("$(Get-Date) >")
}
function drivespace() {
  $env:computername
$disks = Get-WmiObject Win32_LogicalDisk -ComputerName $env:computername -Filter DriveType=3 | 
        Select-Object DeviceID, 
            @{'Name'='Size'; 'Expression'={[math]::truncate($_.size / 1GB)}}, 
            @{'Name'='Freespace'; 'Expression'={[math]::truncate($_.freespace / 1GB)}}
    
    foreach ($disk in $disks)
    {
        $disk.DeviceID + $disk.FreeSpace.ToString("N0") + "GB / " + $disk.Size.ToString("N0") + "GB"

    }
}
try
{
Write-Host "$(timestamp) [INFO] Beginning of drive/volume space cleaning script"
Write-Host "$(timestamp) [INFO] calculating drive space"
(drivespace)
}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered calculating drive space" -ForegroundColor Red
    Write-Error $_
}
try
{
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
    Write-Host "$(timestamp) [INFO] Looking for file(s) older then $TempRetention dayss in $TempPaths..."
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
try
{
    Write-Host "$(timestamp) [INFO] Looking for log file(s) older then $InetPubRetention months in $InetpubLogPaths.."

foreach ($InetpubLogPath in $InetpubLogPaths)
	{
		If (Test-Path $InetpubLogPath)
			{
				Write-Host "$(timestamp) [INFO] path exists $InetpubLogPath"	
				Write-Host "$(timestamp) [INFO] searching for files to compress"					
				foreach ($d in Get-ChildItem -Path $InetpubLogPath)
				{
					Write-Host "$(timestamp) [INFO] calculating total size for files in folder $InetpubLogPath\$d"
					$FolderSize = Get-ChildItem $InetpubLogPath\$d | Measure-Object -Property Length -sum				
					Write-Host "$(timestamp) [INFO] searching for files in folder $InetpubLogPath\$d"
						foreach ($f in Get-ChildItem -Path "$InetpubLogPath\$d" )
						{
								#Write-Host "$(timestamp) [INFO] eval first file files $f"
								if ($f.LastWriteTime -lt (Get-Date).AddMonths(-$InetPubRetention) -And $f.mode -notmatch $Filter)
								{
									#Write-Host "$(timestamp) [INFO] attemp ziping of $f"
									#Write-Host "$(timestamp) [INFO] collecting year of logs"
									$InetpubYear = $f.LastWriteTime.tostring(“yyyy”)
									#Write-Host "$(timestamp) [INFO] year $InetpubYear"
									#Write-Host "$(timestamp) [INFO] checking for zip $InetpubLogPath\$d\$InetpubYear.zip"
									If (Test-Path "$InetpubLogPath\$d\$InetpubYear.zip" )
									{
									#Write-Host "$(timestamp) [INFO] zip found $InetpubLogPath\$d\$InetpubYear.zip"
									#Write-Host "$(timestamp) [INFO] attempt zip of $InetpubLogPath\$d\$f to $InetpubLogPath\$d\$InetpubYear.zip"
									Compress-Archive -Path $f.FullName -Update -DestinationPath $ZipFolder
									Remove-Item -Path $f.FullName -Force
									}
									ELSE
									{
									#Write-Host "$(timestamp) [INFO] zip not found $InetpubLogPath\$d\$InetpubYear.zip"
									#Write-Host "$(timestamp) [INFO] attempt zip of $InetpubLogPath\$d\$f to $InetpubLogPath\$d\$InetpubYear.zip"
									$ZipFolder = "$InetpubLogPath\$d\$InetpubYear.zip"
									Compress-Archive -Path $f.FullName -DestinationPath $ZipFolder
									Remove-Item -Path $f.FullName -Force
									}																	
								}
								ELSE
								{
									#Write-Host "$(timestamp) [INFO] Can't zip $f "
								}							
						}	
					Write-Host "$(timestamp) [INFO] pre compress total $InetpubLogPath\$d"
					echo $FolderSize.Sum
					$FolderSize = Get-ChildItem $InetpubLogPath\$d | Measure-Object -Property Length -sum
					Write-Host "$(timestamp) [INFO] post compress total $InetpubLogPath\$d"
					echo $FolderSize.Sum
				}
			}
			ELSE
			{
				Write-Host "$(timestamp) [INFO] path does not exist $InetpubLogPath"
			}	
	}

}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered ziping $InetPubRetention days in $InetpubLogPaths" -ForegroundColor Red
    Write-Error $_
}
Write-Host "$(timestamp) [INFO] Ended script successfully"
(drivespace)
