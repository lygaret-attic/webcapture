module.exports = function(hotkeyService) {
    return {
        restrict: "A",
        controller: function($rootScope, $document) {
            $document.bind("keydown", function(e) {
                var action = hotkeyService.accept(e);
                if (action) {
                    $rootScope.$broadcast(`hotkey:${action}`, e);
                }
            });
        }
    };
};
