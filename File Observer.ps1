# Prompt user for the file to monitor
$targetFile = Read-Host "Enter the full path of the file to monitor"

# Prompt user for the rechecking interval (in seconds)
$recheckInterval = [int](Read-Host "Enter the rechecking interval in seconds")

try {
    # Infinite loop to monitor the file
    while ($true) {
        if (Test-Path -Path $targetFile) {
            $currentModified = (Get-Item $targetFile).LastWriteTime

            # Get initial last modified timestamp on the first loop
            if (-not $lastModified) {
                $lastModified = $currentModified
            }

            # Compare timestamps
            if ($lastModified -ne $currentModified) {
                Write-Host "File has been edited! ($currentModified)"
                # Add your notification method here (e.g., sending an email, displaying a message box)
            }

            # Update last modified timestamp
            $lastModified = $currentModified
        }

        # Wait for the specified rechecking interval before checking again
        Start-Sleep -Seconds $recheckInterval
    }
} catch {
    Write-Host "Monitoring has been stopped."
}
