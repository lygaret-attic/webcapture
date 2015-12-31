import _ from 'lodash';

const errorMap = {
    'http:401': 'login',
    'http:403': 'login'
};

const errorTransition = _.debounce(($state, $params, ex) => {
    const error = ex.error;
    const errorState = error && errorMap[error];

    if (errorState) {
        // clone state params, since they're mutated in place as the state changes
        let state  = ex.returnTo || $state.current.name;
        let params = ex.returnParams || _.cloneDeep($params);

        $state.go(errorState, { returnTo: state, returnParams: params }, { location: false });
    }

    // don't go more than once if there's cascading failures
    errorTransition.cancel();
}, 500, { leading: true, trailing: false });

const handlerFactory = ['$log', '$injector', ($log, $injector) => {
    return (ex, cause) => {
        const $root = $injector.get('$rootScope');
        $root.$applyAsync(() => {
            const $state = $injector.get('$state');
            const $params = $injector.get('$stateParams');
            errorTransition($state, $params, ex);
        });
    };
}];

export default function install(app) {
    app.factory('$exceptionHandler', handlerFactory);
}
