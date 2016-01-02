import _ from 'lodash';

const listController = ['data.templates', 'list', (templates, list) => {
    var vm = {
        items: list
    };

    vm.remove = (key) => templates
        .delete(key)
        .catch((ex) => { throw ex; });

    return vm;
}];

const createController = ['$state', 'data.templates', ($state, templates) => {
    const vm = {};

    vm.save = () => templates
        .upsert(vm.item)
        .then(() => $state.go('capture.list'))
        .catch((ex) => { throw ex; });

    return vm;
}];

const editorController = ['$state', 'data.templates', 'item', ($state, templates, item) => {
    const vm = {};
    vm.item = _.cloneDeep(item);

    vm.save = () => templates
        .upsert(vm.item.key, vm.item)
        .then(() => $state.go('capture.list'))
        .catch((ex) => { throw ex; });

    return vm;
}];

const captureController = ['$state', 'data.templates', 'item', ($state, templates, item) => {
    const vm = {};

    vm.template = item.template;
    vm.capture  = item.template;

    vm.save = () => { throw "not yet implemented"; };

    return vm;
}];

export function addRoutes(stateP, { name, root }) {
    stateP
        .state(name, {
            abstract: true,
            resolve : {
                user: ['http', (http) => {
                    return http.get('/api/v1/user.json');
                }],

                list: ['data.templates', (templates) => {
                    return templates.list();
                }]
            }
        })
        .state(`${name}.list`, {
            url: '/',
            views: {
                'main@': {
                    templateUrl : 'app/states/capture/list.tpl.html',
                    controllerAs: 'vm',
                    controller  : listController
                }
            }
        })
        .state(`${name}.create`, {
            url: '/new',
            views: {
                'main@': {
                    templateUrl : 'app/states/capture/edit.tpl.html',
                    controllerAs: 'vm',
                    controller  : createController
                }
            }
        })
        .state(`${name}.capture`, {
            url: '/:template',
            resolve: {
                item: ['data.templates', '$stateParams', (templates, $params) => {
                    return templates.get($params.template);
                }]
            },
            views: {
                'main@': {
                    templateUrl : 'app/states/capture/capture.tpl.html',
                    controllerAs: 'vm',
                    controller  : captureController
                }
            }
        })
        .state(`${name}.capture.edit`, {
            url    : '/:template/edit',
            views: {
                'main@': {
                    templateUrl : 'app/states/capture/edit.tpl.html',
                    controllerAs: 'vm',
                    controller  : editorController
                }
            }
        });
}
