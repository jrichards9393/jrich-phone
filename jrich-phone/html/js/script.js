window.addEventListener('message', function(event) {
    let data = event.data;
    console.log('NUI Received:', JSON.stringify(data));
    if (data.action === 'open') {
        console.log('Opening phone UI');
        document.getElementById('phone-container').style.display = 'flex';
        setTimeout(() => {
            console.log('Showing homescreen');
            document.getElementById('lockscreen').style.display = 'none';
            document.getElementById('homescreen').style.display = 'block';
            loadApps();
        }, 2000);
    } else if (data.action === 'loadContacts') {
        console.log('Loading contacts:', data.data);
        let contactsDiv = document.createElement('div');
        data.data.forEach(contact => {
            let p = document.createElement('p');
            p.textContent = `${contact.name}: ${contact.number}`;
            contactsDiv.appendChild(p);
        });
        document.getElementById('homescreen').appendChild(contactsDiv);
    } else if (data.action === 'updateBank') {
        console.log('Bank update:', data.balance);
        alert(`Balance: $${data.balance}`);
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        console.log('Closing phone via Escape');
        fetchNui('close');
    }
});

function loadApps() {
    console.log('Loading apps. Config.Apps:', JSON.stringify(Config.Apps));
    let appsDiv = document.getElementById('apps');
    if (Config.Apps && Config.Apps.length > 0) {
        appsDiv.innerHTML = ''; // Clear existing apps
        Config.Apps.forEach(app => {
            let div = document.createElement('div');
            let img = document.createElement('img');
            img.src = `../images/${app.icon}`;
            let text = document.createElement('span');
            text.textContent = app.name;
            div.appendChild(img);
            div.appendChild(text);
            div.onclick = () => openApp(app.name);
            appsDiv.appendChild(div);
        });
    } else {
        console.log('ERROR: No apps configured in Config.Apps');
    }
}

function openApp(app) {
    console.log('Opening app:', app);
    if (app === 'Contacts') {
        fetchNui('getContacts');
    } else if (app === 'Bank') {
        fetchNui('getBank');
    }
}

function showNotification(title, msg) {
    console.log('Notification:', title, msg);
    let notif = document.createElement('div');
    notif.classList.add('notif');
    notif.innerHTML = `<b>${title}</b><p>${msg}</p>`;
    document.querySelector('.notifications').appendChild(notif);
    setTimeout(() => notif.remove(), 5000);
}

function toggleDarkMode() {
    console.log('Toggling dark mode');
    document.body.classList.toggle('dark-mode');
}

function fetchNui(action, data = {}) {
    console.log('Sending NUI request:', action, data);
    fetch(`https://jrich-phone/${action}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });
}

setInterval(() => {
    let time = new Date().toLocaleTimeString([], {hour: '2-digit', minute: '2-digit', hour12: true});
    document.querySelector('.time').textContent = time;
}, 1000);

/* --- Close handler injected --- */
window.addEventListener('message', function(e) {
    const data = e.data || {};
    if (data && data.action === 'close') {
        console.log('Closing phone UI (NUI message)');
        const cont = document.getElementById('phone-container');
        if (cont) cont.style.display = 'none';
        // optionally reset screens
        const lock = document.getElementById('lockscreen');
        const home = document.getElementById('homescreen');
        if (lock) lock.style.display = 'block';
        if (home) home.style.display = 'none';
    }
});
