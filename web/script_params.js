const btnSaveBlockedApps = document.getElementById('btnSaveBlockedApps')
const url = 'https://68138d49129f6313e211a66e.mockapi.io/management/1';
let appsToBlocked = []

initialize()

btnSaveBlockedApps.addEventListener('click', function() {
    const blockedApps = [];
    const checkboxes = document.querySelectorAll('input[name="blocked_apps"]:checked');
    btnSaveBlockedApps.disabled = true
    const originalText = btnSaveBlockedApps.innerHTML

    checkboxes.forEach(checkbox => {
        blockedApps.push(checkbox.value);
    });
    console.log(blockedApps)

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            appsToBlocked: blockedApps
        })
    })

    let secondsLeft = 5
    const countdown = setInterval(() => {
        secondsLeft--;
        btnSaveBlockedApps.innerText = `Attendez ${secondsLeft}s`;

        if (secondsLeft <= 0) {
            clearInterval(countdown);
            btnSaveBlockedApps.disabled = false;
            btnSaveBlockedApps.innerHTML = originalText;
        }
    }, 1000);
    
})

function setAppsToBlocked() {
    const checkboxes = document.querySelectorAll('input[name="blocked_apps"]');

    checkboxes.forEach(checkbox => {
        if (appsToBlocked.includes(checkbox.value)) {
            checkbox.checked = true;
        } else {
            checkbox.checked = false;
        }
    });
}


function initialize() {
    fetch(url)
        .then(response => response.json())
        .then(data => {
            appsToBlocked = data.appsToBlocked
            setAppsToBlocked()
        })
        .catch(error => {
            console.error('Erreur lors de l\'initialisation:', error);
        });
}
