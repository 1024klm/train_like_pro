exports.init = async function (app) {
    if (!app || !app.ports) {
        console.warn('LocalStorage init skipped: app ports are unavailable.');
        return;
    }

    const storePort = app.ports.storeLocalStorageValue_;
    const getPort = app.ports.getLocalStorage_;
    const receivePort = app.ports.receiveLocalStorage_;

    if (!storePort || typeof storePort.subscribe !== 'function') {
        console.warn('LocalStorage init skipped: storeLocalStorageValue_ port is missing.');
        return;
    }

    if (!getPort || typeof getPort.subscribe !== 'function') {
        console.warn('LocalStorage init skipped: getLocalStorage_ port is missing.');
        return;
    }

    if (!receivePort || typeof receivePort.send !== 'function') {
        console.warn('LocalStorage init skipped: receiveLocalStorage_ port is missing.');
        return;
    }

    storePort.subscribe(data => {
        try {
            localStorage.setItem(data.key, data.value);
        } catch (e) {
            console.error('Error storing data:', e);
        }
    });

    getPort.subscribe(() => {
        try {
            receivePort.send({
                localStorage: {
                    language: (() => {
                        switch (localStorage.getItem('language')) {
                            case 'fr':
                                return 'fr';
                            case 'en':
                                return 'en';
                            default:
                                return (navigator.language || '').toLowerCase().includes('fr') ? 'fr' : 'en';
                        }
                    })(),
                    userPreference: (() => {
                        const stored = localStorage.getItem('userPreference');
                        if (stored === 'dark') return 'dark';
                        if (stored === 'light') return 'light';
                        if (stored === 'system') return 'system';
                        return 'system';
                    })(),
                    systemMode: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
                }
            });
        } catch (e) {
            console.error('Error reading data:', e);
        }
    });

    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        receivePort.send({
            localStorage: {
                language: localStorage.getItem('language') || ((navigator.language || '').toLowerCase().includes('fr') ? 'fr' : 'en'),
                userPreference: localStorage.getItem('userPreference') || 'system',
                systemMode: e.matches ? 'dark' : 'light'
            }
        });
    });
}
