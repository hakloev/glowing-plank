import './main.css'
import { Main } from './Main.elm'
import registerServiceWorker from './registerServiceWorker'
import sonos from 'sonos'

const HUE_CONFIG = {
    username: 'Q24Bao7PrQYunRG8iIWDt0LYrXPoO53rQVclvotD',
    bridgeIp: '10.0.33.13',
}

const flags = {
    'hueApiUrl': `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/`,
    'currentTime': Date.now(),
    'ruterConfig': {
            'stopId': 3012120,
            'timeToStop': 3,
            'excludedLines': [
                "Vestli",
            ]
    },
}

const app = Main.embed(document.getElementById('root'), flags);

app.ports.stopAvailableSonosDevices.subscribe(() => {
    sonos.search(device => {
        device.stop((error, stopped) => {
            console.log([error, stopped]);
        })
    })
})

registerServiceWorker()

