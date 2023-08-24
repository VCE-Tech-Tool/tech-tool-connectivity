<#
Script: VCE Tech Tool connectivity.ps1
Description: A PowerShell script to test TCP connections to hosts required by Tech Tool 2.8.210
Version: 1.0.2
Date: 2023-08-24
Company: Volvo Construction Equipment
Author: Mustafa Çetinkaya
#>

function Test-Connection {
    param(
        [string]$Target,
        [int]$Port
    )

    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.ReceiveTimeout = 10000

    try {
        Write-Host "Testing connection to $Target on port $Port..."
        $connection.Connect($Target, $Port)
        if ($connection.Connected) {
            Write-Host "Connected to $Target on port $Port - Success" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to connect to $Target on port $Port" -ForegroundColor Red
        }
    } catch [System.Net.Sockets.SocketException] {
        $errorCode = $_.Exception.ErrorCode
        Write-Host "Failed to connect to $Target on port $Port (Error code: $errorCode)" -ForegroundColor Red
        Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Red
    } catch {
        Write-Host "Failed to connect to $Target on port $Port" -ForegroundColor Red
        Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $connection.Close()
    }
    return $false
}

# Registering a trap for Ctrl+C (SIGINT)
$trapAction = {
    Write-Host "`nCtrl+C pressed. Exiting the script..."
    exit 1
}

trap { & $trapAction; continue }

Write-Host "`n`t`t`t`t`t`t`t`t`t`tVolvo Construction Equipment 2023`n"
Write-Host "This program will check your computer against the new requirements for the upcoming Tech Tool v2.8.210 release."
Write-Host "It will establish test connections to Volvo services and display a summary of the test result in the end."
Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Clear-Host

# Test TT network connection requirements
$targets = @(
    @{ Target = "hmgmobile.it.volvo.com"; Port = 2010 },
    @{ Target = "baldoauthserviceprod-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "embla-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "ppd-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "genericlogger-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "namsppd-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "namsadmin-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "gdsp-volvogroup.msappproxy.net"; Port = 443 },
    @{ Target = "wbimb1-volvogroup.msappproxy.net"; Port = 443 }
    @{ Target = "wbimb2-volvogroup.msappproxy.net"; Port = 443 }
)

$successCount = 0
$failureCount = 0
$failureDetails = @()

foreach ($targetInfo in $targets) {
    if (Test-Connection -Target $targetInfo.Target -Port $targetInfo.Port) {
        $successCount++
    } else {
        $failureCount++
        $failureDetails += "Failed to connect to $($targetInfo.Target) on port $($targetInfo.Port)."
    }
}

Write-Host "`n===== Test Summary =====`n"
Write-Host "Successful Connections: $successCount" -ForegroundColor Green
Write-Host "Failed Connections: $failureCount" -ForegroundColor Red

if ($failureCount -gt 0) {
    Write-Host "`n----- Failure Details -----"
    $failureDetails | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }
}

# Wait for Ctrl+C to close the window
Write-Host "`nPress Ctrl+C to close this window..."
while ($true) {
    Start-Sleep -Milliseconds 100
}
