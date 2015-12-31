const authFactory = ['http', 'token', '$q', '$timeout', (http, token, $q, $timeout) => {
    var svc = {};

    var user  = null;
    var userP = null;

    svc.get = () => {
        if (user)  { return $q.resolve(user); }
        if (userP) { return userP; }

        return userP = http
            .get('/api/v1/user.json')
            .then((resp) => (user = resp.data));
    };

    svc.auth = (username, password) => {
        return http
            .post('/api/v1/user/token', { scopes: ['any'] }, { username, password })
            .then((data) => {
                token.set(data.token);
                return true;
            });
    };

    svc.deauth = () => {
        token.set(null);
    };

    return svc;
}];

export default function install(app) {
    app.factory('auth', authFactory);
}
