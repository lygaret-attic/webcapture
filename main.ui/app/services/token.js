const tokenFactory = ['$window', '$log', ($window, $log) => {
    const svc   = {};
    const key   = 'capture.auth';
    const store = $window.localStorage;

    svc.get = () => store.getItem(key);
    svc.set = (token) => {
        if (!!token) { store.setItem(key, token); }
        else         { store.removeItem(key);     }
    };

    return svc;
}];

export default function install(app) {
    app.factory('token', tokenFactory);
}
