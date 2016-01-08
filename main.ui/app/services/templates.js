import _ from 'lodash';
import { deepFreeze } from '../util';

const whitelist  = ['template'];
const properties = ['description'];
const toModel    = (obj) => {
    let res = { properties: {} };

    for (let key of whitelist) {
        res[key] = obj[key];
    }

    for (let key of properties) {
        res.properties[key] = obj.properties && obj.properties[key];
    }

    return res;
};

const templatesFactory = ['http', '$q', '$log', (http, $q, $log) => {
    var svc = {};

    var cache  = null;
    var cacheP = null;

    /*
     Templates have the following properties:

     key     : primary key, generated server side
     template: template string
     properties: {
         description: plain text
     }
     */

    const fetch = () => {
        if (cache)  { return $q.resolve(cache); }
        if (cacheP) { return cacheP; }

        return cacheP = http.get('/api/v1/templates')
            .then((data) => cache = data.map(deepFreeze));
    };

    svc.list = () => {
        return fetch();
    };

    svc.get = (key) => {
        return fetch()
            .then((ts) => _.find(ts, { key }))
            .then((res) => {
                if (!res) { throw { error: 'http:404' }; }
                return res;
            });
    };

    svc.fragment = (key) => {
        return http.get(`/api/v1/templates/${key}.frag`);
    };

    svc.upsert = (key, obj = null) => {
        if (typeof(key) === "object" && obj === null) {
            obj = key; key = null;
        }

        const template = toModel(obj);
        const request  = key == null ?
                  http.post('/api/v1/templates', { template }) :
                  http.put(`/api/v1/templates/${key}`, { template }) ;

        return $q.all([fetch(), request])
            .then(([cache, result]) => {
                let index = _.findIndex(cache, { key: result.key });
                if (index >= 0) {
                    cache.splice(index, 1, deepFreeze(result));
                } else {
                    cache.push(deepFreeze(result));
                }

                return result;
            });
    };

    svc.delete = (key) => {
        const request = http.delete(`/api/v1/templates/${key}`);
        return $q.all([fetch(), request])
            .then(([cache, result]) => {
                let index = _.findIndex(cache, { key });
                if (index >= 0) {
                    cache.splice(index, 1);
                }

                return result;
            });
    };

    return svc;
}];

export default function install(app) {
    app.factory('data.templates', templatesFactory);
}
