import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const HUE_CONFIG = {
    username: 'Q24Bao7PrQYunRG8iIWDt0LYrXPoO53rQVclvotD',
    bridgeIp: '10.0.33.13',
};

const flags = {
    'HUE_API_URL': `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/`,
    'RUTER': {
        'stops': [
            {
                'stopId': 3012120,
                'timeToStop': 4,
            },
            {
                'stopId': 3012121,
                'timeToStop': 5,
            }
        ]
    }
}

const app = Main.embed(document.getElementById('root'), flags);

registerServiceWorker();

