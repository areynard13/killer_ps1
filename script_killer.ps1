Add-Type -AssemblyName System.Windows.Forms

# Déclaration des variables globales
$isActive = $null
$message = $null
$messageIncr = $null
$lastMessageIncr = ""

function checkDataBase {
    $response = Invoke-RestMethod -Uri "https://68138d49129f6313e211a66e.mockapi.io/management" -Method Get
    
    $global:isActive = $response.isActive
    $global:message = $response.message.message
    $global:messageIncr = $response.message.incr
}

function closeApp {
    $blacklist = @('chrome', 'msedge', 'code')

    while ($true) {
        Get-Process | Where-Object { $blacklist -contains $_.Name } | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
                Write-Host "Processus bloqué : $($_.Name)" -ForegroundColor Red
            } catch {}
        }

        Start-Sleep -Milliseconds 500
    }
}

function closeAppTest {
    while ($true) {
        Write-Host "killer actif (simulation)" -ForegroundColor Magenta
        Start-Sleep -Milliseconds 500
    }
}

function showMessageBox {
    param (
        [string]$message,
        [string]$title = "Message"
    )

    [System.Windows.Forms.MessageBox]::Show($message, $title, 'OK', 'Information')
}

# Fonction principale
function main {
    $jobCloseApp = $null
    $isRunning = $false

    checkDataBase
    $global:lastMessageIncr = $messageIncr

    while ($true) {
        checkDataBase

        Write-Host "isActive = $isActive, messageIncr = $messageIncr" -ForegroundColor Cyan

        if ($messageIncr -ne $lastMessageIncr) {
            if ($messageIncr -ne "") {
                showMessageBox -message $message
            }
            $global:lastMessageIncr = $messageIncr
        }

        if ($isActive -and -not $isRunning) {
            $jobCloseApp = Start-Job -ScriptBlock ${function:closeAppTest}
            $isRunning = $true
            Write-Host "killer lancé (simulé)" -ForegroundColor Green
        }
        elseif (-not $isActive -and $isRunning) {
            Stop-Job $jobCloseApp
            Wait-Job $jobCloseApp
            Remove-Job $jobCloseApp
            $isRunning = $false
            Write-Host "killer arrêté (simulé)" -ForegroundColor Yellow
        }

        Start-Sleep -Seconds 10
    }
}

# Lancer le programme
main
