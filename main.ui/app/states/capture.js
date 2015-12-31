export function addRoutes(stateP, { name, root }) {
    stateP
        .state(name, {
            abstract: true,
            resolve : {
                user: (http) => {
                    return http.get('/api/v1/user.json');
                }
            }
        })
        .state(`${name}.list`, {
            url: '',
            views: {
                'main@': {
                    template: '{{ user.email }} <a ui-sref="capture.editor({ template: \'abc\' })">blah</a>',
                    controller: function($scope, user) {
                        $scope.user = user;
                    }
                }
            }
        })
        .state(`${name}.editor`, {
            url: '/:template',
            views: {
                'main@': {
                    template: '{{ user.email }} <a ui-sref="capture.list">list</a>',
                    controller: function($scope, user) {
                        $scope.user = user;
                    }
                }
            }
        });
}
