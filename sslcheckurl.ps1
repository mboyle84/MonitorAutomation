#written by: Mike B
#Contact:
#
#error handling and logging
#Set-StrictMode -Version latest
$Error.clear()
$Error
$ErrorActionPreference = "Stop"
$Logfile = "C:\urlcheckfromvsclog.log"
$urlsfile = "C:\urls.csv"
$certAge = 60

function timestamp() {
    return ("$(Get-Date) >")
}


try
{
Write-output "$(timestamp) [INFO] Beginning of testing script" 
Write-output "$(timestamp) [INFO] attempt to read file $urlsfile"
Write-output "$(timestamp) [INFO] setting certificate validation check to true" 
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$url1=@()
Import-Csv $urlsfile | ForEach-Object {
    #$url1 += $_.url
	$url1 =$($_.url)
	$url = [string]$url1
	#Write-output "$(timestamp) [INFO] url $($_.url) "
	$req = [Net.HttpWebRequest]::Create($url)
	$req.GetResponse() | Out-Null
	$certeffective =	$req.ServicePoint.Certificate.GetEffectiveDateString()
	$certexpiration =	$req.ServicePoint.Certificate.GetExpirationDateString()
	#Write-output "$(timestamp) [INFO] SSL expires on $certexpiration"	
	$req.Abort()
	$expiry = (get-date).AddDays(+$certAge) 
	#Write-output "$(timestamp) [INFO] $certAge days from today is $expiry "
	if ($expiry -gt $certexpiration)
    {
				Write-output "$(timestamp) [INFO] $url expires within $certAge days on $certexpiration"  
    }
    else
    {	
				#Write-output "$(timestamp) [INFO] $url is valid until $certexpiration"
    }
	
}

}
catch
{
    Write-output "$(timestamp) [ERROR] Encountered testing"
    Write-output $_ 
}
Write-output "$(timestamp) [INFO] Script complete" 
