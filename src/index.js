import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const HUE_CONFIG = {
    username: 'Q24Bao7PrQYunRG8iIWDt0LYrXPoO53rQVclvotD',
    bridgeIp: '10.0.33.13',
};

const flags = {
    "HUE_API_URL": `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/`,
}

const app = Main.embed(document.getElementById('root'), flags);

app.ports.turnOffHueLights.subscribe(() => {
    getAllHueLights()
        .then(r => {
            console.log('all off')
            app.ports.hueLightRequestDone.send(true)
        })
        .catch(e => {
            console.log('something failed')
            app.ports.hueLightRequestDone.send(false)
        })
});

const getAllHueLights = () => {
    const url = `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/lights`
    return fetch(url)
        .then(r => r.json())
        .then(r => {
            const turnOffPromises = Object.keys(r).map(lightId => setLightState(lightId, false))

            const testPromise = new Promise((resolve, reject) => {
                setTimeout(resolve, 500, true)
            })

            return Promise.all([...turnOffPromises, testPromise])
                .then(values => console.log(values))
        })
}

const setLightState = (id, on = false) => {
    const url = `http://${HUE_CONFIG.bridgeIp}/api/${HUE_CONFIG.username}/lights/${id}/state`
    const body = { on, }

    return new Promise((resolve, reject) => {
        return fetch(url, {
            method: 'PUT',
            body: JSON.stringify(body),
        })
            .then(r => r.json())
            .then(r => {
                resolve(true)
            })
            .catch(e => reject(false))
    })

}


registerServiceWorker();

