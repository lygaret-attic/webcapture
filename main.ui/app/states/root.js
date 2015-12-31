const rootController = ['$rootScope', '$scope', '$state', ($root, $scope, $state) => {
    const root = {};

    root.routeChanging = false;

    $root.$on('$stateChangeStart', () => root.routeChanging = true);
    $root.$on('$stateChangeSuccess', () => root.routeChanging = false);
    $root.$on('$stateChangeError', (event, toState, toParams, fromState, fromParams, ex) => {
        root.routeChanging = false;

        ex.returnTo = toState.name;
        ex.returnParams = toParams;
        throw ex;
    });

    return root;
}];

export default function install(app) {
    app.controller('rootController', rootController);
}
