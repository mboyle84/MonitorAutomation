#written by: Mike B 
#Contact:
#
#error handling and logging
#Set-StrictMode -Version latest
$Error.clear()
$Error
$ErrorActionPreference = "Stop"


function timestamp() {
    return ("$(Get-Date) >")
}


try
{
Write-Host "$(timestamp) [INFO] Beginning of logout disconnect session script"

$sessions = query user /server:$env:computername | select -skip 1;

Write-Host "$(timestamp) [INFO] dump sessions from server $env:computername " 
echo $sessions

Write-Host "$(timestamp) [INFO] Loop through sessions/line returnes to find disconnected sessions"

foreach ($line in $sessions) { 
 
    $line = -split $line;
 

    if ($line.length -eq 8) {
 
        # Get current session state (column 4)
        $state = $line[3];
        # Get Session ID (column 3) and current idle time (column 5)
        $sessionid = $line[2]; 
        $idletime = $line[4];
        $username = $line[0];
    #    Write-Host "$(timestamp) [INFO] Session Info server $env:computername ....Username: $username State: $state SessionID: $sessionid Ideltime: $idletime"

 
    } else {
 
        # Get current session state (column 3)
        $state = $line[2];
 
        # Get Session ID (column 2) and current idle time (column 4)
        $sessionid = $line[1]; 
        $idletime = $line[3];
        $username = $line[0];
     #    Write-Host "$(timestamp) [INFO] Session Info server $env:computername ....Username: $username State: $state SessionID: $sessionid Ideltime: $idletime"
    }
   
    # If the session state is Disconnected 
    if ($state -eq "Disc") { 
 
        # Check if idle for more than 1 day (has a '+') and log off 
        if ($idletime -like "*+*") {
 
            Write-Host "$(timestamp) [WARNING] suggesting logging out session more than 1 day on server $env:computername ... $sessionid username: $username from server $env:computername  " -ForegroundColor DarkYellow
           # logoff $sessionid /server:$env:computername /v
 
        # Check if idle for more than 1 hour (has a ':') and log off 
        } elseif ($idletime -like "*:*") {
            
            Write-Host "$(timestamp) [WARNING] suggesting logging out session more 1 hour on server $env:computername ... $sessionid username: $username from server $env:computername" -ForegroundColor DarkYellow
           # logoff $sessionid /server:$env:computername /v
 
        } 
    }
}

$sessions = query user /server:$env:computername | select -skip 1;

Write-Host "$(timestamp) [INFO] dump sessions to screen from server $env:computername " 
echo $sessions 
 

    
}
catch
{
    Write-Host "$(timestamp) [ERROR] Encountered processing sessions" -ForegroundColor Red
    Write-Error $_
    exit 1
}


Write-Host "$(timestamp) [INFO] Ended script successfully"

