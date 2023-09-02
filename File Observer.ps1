##############################################################################
#PROGRAM: FILE OBSERVER
#VERSION: 1.1(BETA)
#DESCRIPTION: A handy little tool to see if a targeted file is being modified
##############################################################################

# Specify the path to the configuration file
$configFilePath = "config"

try {
    # Check if the configuration file exists
    if (Test-Path -Path $configFilePath) {
        # Read the configuration settings from the file
        $configSettings = Get-Content -Path $configFilePath | ForEach-Object {
            $setting = $_ -split '='
            [PSCustomObject]@{
                Name = $setting[0].Trim()
                Value = $setting[1].Trim()
            }
        }

        # Find and set the recheckInterval value from the configuration
        $recheckIntervalSetting = $configSettings | Where-Object { $_.Name -eq 'recheckIntervalInSeconds' }
        if ($recheckIntervalSetting -ne $null) {
            $recheckInterval = [int]$recheckIntervalSetting.Value
        }
    } else {
        # Configuration file not found, prompt the user for values
        $recheckInterval = Read-Host "Enter the rechecking interval in seconds"
        
        # Create a new configuration file with the provided values
        Set-Content -Path $configFilePath -Value "recheckIntervalInSeconds=$recheckInterval"
        Write-Host "Configuration file created with the provided values."
    }

	# Prompt user for the file to monitor
	$targetFile = Read-Host "Enter the full path of the file to monitor"

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
} catch {
    Write-Host "Error: Could not read the configuration file."
}
