const captureFactory = ['http', (http) => {
}];

export default function install(app) {
    app.factory('capture', captureFactory);
}
