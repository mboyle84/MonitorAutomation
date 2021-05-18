#written by: Mike
#Contact: 
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
$NodeLogfile = "C:\DriveCleanupLog.txt"
$eventsource = "SCDriveSpaceCleanerRemote.ps1"

function timestamp() {
    return ("$(Get-Date) >")
}
function drivespace() {
  #$env:computername
$disks = Get-WmiObject Win32_LogicalDisk -ComputerName $env:computername -Filter DriveType=3 | 
        Select-Object DeviceID, 
            @{'Name'='Size'; 'Expression'={[math]::truncate($_.size / 1GB)}}, 
            @{'Name'='Freespace'; 'Expression'={[math]::truncate($_.freespace / 1GB)}}
    
    foreach ($disk in $disks)
    {
        $disk.DeviceID + $disk.FreeSpace.ToString("N0") + "GB / " + $disk.Size.ToString("N0") + "GB" >> $NodeLogfile
    }
}
try
{
Write-output "$(timestamp) [INFO] Beginning of drive/volume space cleaning script"  >> $NodeLogfile
New-EventLog -LogName Application -Source $eventsource -ErrorAction Ignore| Out-Null
Write-EventLog -LogName "Application" -Source $eventsource -EventID 3001 -EntryType Information -Message "Beginning of drive/volume space cleaning script, for more details review log at D:\Scripts\Logs\DriveCleanupConnectionLog.txt" -Category 1 -RawData 10,20
whoami >> $NodeLogfile
Write-output "$(timestamp) [INFO] calculating drive space on "$SystemName >> $NodeLogfile
(drivespace)        
}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered calculating drive space" >> $NodeLogfile
    Write-output $_ >> $NodeLogfile
}
try
{
Write-output "$(timestamp) [INFO] Remove attempt of $RecycleBinPaths $WindowsOld" >> $NodeLogfile
foreach ($RecycleBinPath in $RecycleBinPaths)
	{
		If (Test-Path $RecycleBinPath)
			{
				Write-output "$(timestamp) [INFO] path exists $RecycleBinPath"	>> $NodeLogfile 
				Remove-Item $RecycleBinPath -Recurse -Force -ErrorAction SilentlyContinue
				Write-output "$(timestamp) [INFO] path removed $RecycleBinPath"	>> $NodeLogfile
			}
			ELSE
			{
				Write-output "$(timestamp) [INFO] path does not exist $RecycleBinPath" >> $NodeLogfile
			}	
	}

	Write-output "$(timestamp) [INFO] Remove attempt of  $WindowsOld" >> $NodeLogfile
	If (Test-Path $WindowsOld)
	{
		Write-output "$(timestamp) [INFO] path exists $WindowsOld"	>> $NodeLogfile
		Remove-Item $WindowsOld -Recurse -Force -ErrorAction SilentlyContinue
	}
	ELSE
	{
		Write-output "$(timestamp) [INFO] path does not exist $WindowsOld" >> $NodeLogfile
	}

}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered removing $RecycleBinPaths $WindowsOld" >> $NodeLogfile
    Write-output $_ >> $NodeLogfile
}
try
{
    Write-output "$(timestamp) [INFO] Looking for file(s) older then $TempRetention dayss in $TempPaths..." >> $NodeLogfile
	foreach ($TempPath in $TempPaths)
	{
		If (Test-Path $TempPath)
			{
				Write-output "$(timestamp) [INFO] path exists $TempPath" >> $NodeLogfile	
				Write-output "$(timestamp) [INFO] searching for files to remove" >> $NodeLogfile	
				
				foreach ($i in Get-ChildItem -Path $TempPath -Recurse)
				{
					if ($i.LastWriteTime -lt (Get-Date).AddDays(-$TempRetention) -And $i.mode -notmatch $Filter)
					{
						Write-output "$(timestamp) [INFO] attemp removal of $i" >> $NodeLogfile
						Remove-Item -Path $i.FullName -Force -ErrorAction SilentlyContinue
						#Write-output "$(timestamp) [INFO] Removed of $TempPath directory with last date $i.LastWriteTime" >> $NodeLogfile
					}
					ELSE
					{
						#Write-output "$(timestamp) [INFO] Can't Removed $i " >> $NodeLogfile
					}
				}
			}
			ELSE
			{
				Write-output "$(timestamp) [INFO] path does not exist $TempPath" >> $NodeLogfile
			}	
	}	
}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered removing $TempRetention days in $TempPaths" >> $NodeLogfile
    Write-output $_ >> $NodeLogfile
}
try
{
    Write-output "$(timestamp) [INFO] Looking for log file(s) older then $InetPubRetention months in $InetpubLogPaths.." >> $NodeLogfile

foreach ($InetpubLogPath in $InetpubLogPaths)
	{
		If (Test-Path $InetpubLogPath)
			{
				Write-output "$(timestamp) [INFO] path exists $InetpubLogPath"	>> $NodeLogfile
				Write-output "$(timestamp) [INFO] searching for files to compress"	>> $NodeLogfile				
				foreach ($d in Get-ChildItem -Path $InetpubLogPath)
				{
					Write-output "$(timestamp) [INFO] calculating total size for files in folder $InetpubLogPath\$d" >> $NodeLogfile
					$FolderSize = Get-ChildItem $InetpubLogPath\$d | Measure-Object -Property Length -sum				
					Write-output "$(timestamp) [INFO] searching for files in folder $InetpubLogPath\$d" >> $NodeLogfile
						foreach ($f in Get-ChildItem -Path "$InetpubLogPath\$d" )
						{
								#Write-output "$(timestamp) [INFO] eval first file files $f" >> $NodeLogfile
								if ($f.LastWriteTime -lt (Get-Date).AddMonths(-$InetPubRetention) -And $f.mode -notmatch $Filter)
								{
									#Write-output "$(timestamp) [INFO] attemp ziping of $f" >> $NodeLogfile
									#Write-output "$(timestamp) [INFO] collecting year of logs" >> $NodeLogfile
									$InetpubYear = $f.LastWriteTime.tostring(“yyyy”)
									#Write-output "$(timestamp) [INFO] year $InetpubYear" >> $NodeLogfile
									#Write-output "$(timestamp) [INFO] checking for zip $InetpubLogPath\$d\$InetpubYear.zip" >> $NodeLogfile
									If (Test-Path "$InetpubLogPath\$d\$InetpubYear.zip" )
									{
									#Write-output "$(timestamp) [INFO] zip found $InetpubLogPath\$d\$InetpubYear.zip" >> $NodeLogfile
									#Write-output "$(timestamp) [INFO] attempt zip of $InetpubLogPath\$d\$f to $InetpubLogPath\$d\$InetpubYear.zip" >> $NodeLogfile
									Compress-Archive -Path $f.FullName -Update -DestinationPath $ZipFolder
									Remove-Item -Path $f.FullName -Force
									}
									ELSE
									{
									#Write-output "$(timestamp) [INFO] zip not found $InetpubLogPath\$d\$InetpubYear.zip" >> $NodeLogfile
									#Write-output "$(timestamp) [INFO] attempt zip of $InetpubLogPath\$d\$f to $InetpubLogPath\$d\$InetpubYear.zip" >> $NodeLogfile
									$ZipFolder = "$InetpubLogPath\$d\$InetpubYear.zip"
									Compress-Archive -Path $f.FullName -DestinationPath $ZipFolder
									Remove-Item -Path $f.FullName -Force
									}																	
								}
								ELSE
								{
									#Write-output "$(timestamp) [INFO] Can't zip $f " >> $NodeLogfile
								}							
						}	
					Write-output "$(timestamp) [INFO] pre compress total $InetpubLogPath\$d" >> $NodeLogfile
					echo $FolderSize.Sum
					$FolderSize = Get-ChildItem $InetpubLogPath\$d | Measure-Object -Property Length -sum
					Write-output "$(timestamp) [INFO] post compress total $InetpubLogPath\$d" >> $NodeLogfile
					echo $FolderSize.Sum
				}
			}
			ELSE
			{
				Write-output "$(timestamp) [INFO] path does not exist $InetpubLogPath" >> $NodeLogfile
			}	
	}

}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered ziping $InetPubRetention days in $InetpubLogPaths" >> $NodeLogfile
    Write-output $_ >> $NodeLogfile
}
Write-output "$(timestamp) [INFO] Ended script successfully" >> $NodeLogfile
(drivespace)
Write-EventLog -LogName "Application" -Source $eventsource -EventID 3001 -EntryType Information -Message "Ended script successfully, for more details review log at D:\Scripts\Logs\DriveCleanupConnectionLog.txt" -Category 1 -RawData 10,20

