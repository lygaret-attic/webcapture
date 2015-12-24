module.exports = function() {
    require('./template-picker.scss');

    return {
        restrict: 'A',
        template: require('./template-picker.html'),
        scope   : {
            templates: '='
        },

        controller: function($scope, $document, hotkeyService) {
            hotkeyService.register("C-c C-c", "template-picker-accept");
            hotkeyService.register("C-c C-k", "template-picker-ignore");

            $scope.$on('hotkey:template-picker-accept', function($event) {
                console.log('got template picker accept');
            });
        }
    };
};
