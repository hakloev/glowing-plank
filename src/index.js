import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const HUE_CONFIG = {
    username: 'Q24Bao7PrQYunRG8iIWDt0LYrXPoO53rQVclvotD',
    bridgeIp: '10.0.33.13',
};

const flags = {
    'hueApiUrl': `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/`,
    'ruterConfig': {
            'stopId': 3012120,
            'timeToStop': 3,
            'excludedLines': [
                "Vestli",
            ]
    },
    'now': Date.now()
}

const app = Main.embed(document.getElementById('root'), flags);

registerServiceWorker();

