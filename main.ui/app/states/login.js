export function addRoutes(stateP, { name, root }) {
    stateP.state(name, {
        params: { returnTo: '', returnParams: {} },
        views: {
            main: {
                templateUrl: 'app/states/login/index.tpl.html',
                controllerAs: 'login',
                controller  : loginController
            }
        }
    });
}

const loginController = ['auth', '$state', '$stateParams', (auth, $state, $params) => {
    var login = {};

    login.error = false;

    login.login = (email, password) => {
        return auth.auth(email, password)
            .then(() => {
                $state.go($params.returnTo, $params.returnParams);
            })
            .catch((err) => {
                login.error = true;
            });
    };

    return login;
}];
