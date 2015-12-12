const angular = require('angular');
require('angular-sanitize');

/* load up widgets and such */
const capture = angular.module('webcapture', ['ngSanitize']);
capture.provider('captureService', require('./service/capture-service'));
capture.directive('captureTemplate', require('./widgets/capture-template'));

/* bootstrap into the root */
const root = document.getElementById('root');
angular.bootstrap(root, ['webcapture'], { strictDi: true });
