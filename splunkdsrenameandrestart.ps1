# Define the file path and the renamed file path
$filePath = "C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf"
$renamedFilePath = "$filePath.old"

# Check if the file exists
Write-Output "Checking if the file exists at: $filePath"
if (Test-Path -Path $filePath) {
    Write-Output "File found. Renaming it to: $renamedFilePath"
    Rename-Item -Path $filePath -NewName $renamedFilePath -ErrorAction Stop
} else {
    Write-Output "File does not exist: $filePath"
}

# Attempt to stop the service
Write-Output "Attempting to stop SplunkForwarder service..."
try {
    Write-Output "Stopping the SplunkForwarder service now..."
    # Stop the service first
    Stop-Service -Name "SplunkForwarder" -Force -ErrorAction Stop
    Write-Output "SplunkForwarder service stopped successfully."
} catch {
    Write-Output "Failed to stop SplunkForwarder service: $_"
    Write-Output "Proceeding to start the service..."
}

# Wait for 30 seconds before starting the service
Write-Output "Waiting for 30 seconds to ensure the service is ready to start..."
Start-Sleep -Seconds 30

# Attempt to start the service
Write-Output "Attempting to start SplunkForwarder service..."
try {
    Write-Output "Starting the SplunkForwarder service now..."
    # Start the service
    Start-Service -Name "SplunkForwarder" -ErrorAction Stop
    Write-Output "SplunkForwarder service started successfully."
} catch {
    Write-Output "Failed to start SplunkForwarder service: $_"
}
