function checkDataBase {
    $response = Invoke-RestMethod -Uri "https://68138d49129f6313e211a66e.mockapi.io/management" -Method Get
    return $response.isActive
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

function main {
    $job = $null
    $isRunning = $false

    while ($true) {
        $isActive = checkDataBase
        Write-Host "isActive = $isActive" -ForegroundColor Cyan

        if ($isActive -and -not $isRunning) {
            $job = Start-Job -ScriptBlock ${function:closeAppTest}
            $isRunning = $true
            Write-Host "killer lancé (simulé)" -ForegroundColor Green
        }
        elseif (-not $isActive -and $isRunning) {
            Stop-Job $job
            Wait-Job $job
            Remove-Job $job
            $isRunning = $false
            Write-Host "killer arrêté (simulé)" -ForegroundColor Yellow
        }

        Start-Sleep -Seconds 10
    }
}

# Lancer le programme
main