require('angular');
require('angular-sanitize');
require('angular-ui-router');

require('./index.scss');

const capture = angular.module('webcapture', ['ngSanitize', 'ui.router']);

capture.provider('hotkeyService', require('./service/hotkey-service'));
capture.directive('hotkeyListener', require('./service/hotkey-listener'));

capture.provider('templateService', require('./service/template-service'));
capture.provider('captureService', require('./service/capture-service'));

capture.directive('templatePicker', require('./widgets/template-picker'));
capture.directive('captureTemplate', require('./widgets/capture-template'));

capture.config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
    $stateProvider
        .state('root', {
            abstract: true,
            template: require('./root.html')
        })
        .state('root.templates', {
            url: '',
            resolve: {
                templates: function(templateService) {
                    return templateService.list();
                }
            },
            views: {
                widget: {
                    template: '<div class="widget" template-picker templates="templates" />',
                    controller: function($scope, templates) {
                        $scope.templates = templates;
                    }
                },
                help: {
                    template: '<span>Type a <em>(hotkey)</em>, or click a link.</span>'
                }
            }
        })
        .state('root.capture', {
            url: '/:key',
            template: '<div class="widget" capture-template template="template" />',
            resolve: {
                template: function($stateParams, templateService) {
                    return templateService.get($stateParams.key);
                }
            },
            controller: function($scope, template) {
                $scope.template = template;
            }
        });
}]);

/* bootstrap into the root */
const root = document.getElementById("root");
angular.bootstrap(root, ['webcapture'], { strictDi: false });
