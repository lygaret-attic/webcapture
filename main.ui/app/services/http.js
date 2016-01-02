import _ from 'lodash';

const httpFactory = ['$http', '$q', 'token', ($http, $q, token) => {
    const svc = (config) => {
        config.headers = config.headers || {};
        config.headers['X-Requested-With'] = 'XMLHttpRequest';
        config.headers['Authorization'] = config.headers['Authorization'] || () => {
            let { username, password } = config;
            if (username && password) {
                let hash = window.btoa(`${username}:${password}`);
                return `Basic ${hash}`;
            }

            if (token.get()) {
                return `Token token="${token.get()}"`;
            }
        };

        // keep an active count
        svc.activeRequests += 1;

        // install our 'interceptors'
        return $http(config)
            .finally(function() {
                svc.activeRequests -= 1;
            });
    };

    // copied from angular source, build shortcut methods

    const handle = (response) => {
        if (response.status.toString()[0] !== '2') { // response is a {3,4,5}xx
            const error = `http:${response.status}`;
            throw { error, data: response.data };
        }

        return response.data;
    };

    _.each(['get', 'delete', 'head', 'jsonp'], (method) => {
        svc[method] = (url, config = {}) => svc({ ...config, method, url }).then(handle, handle);
    });

    _.each(['post', 'put', 'patch'], (method) => {
        svc[method] = (url, data, config = {}) => svc({ ...config, method, url, data }).then(handle, handle);
    });

    svc.raw = {};

    _.each(['get', 'delete', 'head', 'jsonp'], (method) => {
        svc.raw[method] = (url, config = {}) => svc({ ...config, method, url });
    });

    _.each(['post', 'put', 'patch'], (method) => {
        svc.raw[method] = (url, data, config = {}) => svc({ ...config, method, url, data });
    });

    svc.activeRequests = 0;
    return svc;
}];

export default function install(app) {
    app.factory('http', httpFactory);
}
