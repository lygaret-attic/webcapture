module.exports = ['$timeout', '$sce', function($timeout, $sce, capture) {
    require("./capture-template.scss");

    var angular = require('angular');

    function lineOptional(reified, escape, template, value) {
        if (value && value.length) {
            value = template.replace("%%", value);
            return reified.replace(escape, value);
        } else {
            var lineRe = new RegExp("^\\s*" + escape + "(?:\\s*$\\n?)?", "mg");
            return reified.replace(lineRe, "");
        }
    }

    function parseTemplate(template, context = {}) {
        var reified = template;
        reified = reified.replace("%?", "<span class='cursor'></span>");
        reified = reified.replace("%t", "<span class='timestamp active'>&lt;2015-12-10&gt;</span>");
        reified = reified.replace("%T", "<span class='timestamp active'>&lt;2015-12-10 23:30&gt;</span>");
        reified = reified.replace("%u", "<span class='timestamp inactive'>[2015-12-10]</span>");
        reified = reified.replace("%U", "<span class='timestamp inactive'>[2015-12-10 23:30]</span>");

        reified = lineOptional(reified, "%i", "%%", context.initial);
        reified = lineOptional(reified, "%a", "[[%%]]", context.annotation);
        reified = lineOptional(reified, "%A", "[[%%]]", context.annotation);
        reified = lineOptional(reified, "%l", "%%", context.annotation);

        reified = reified.replace("\n", "<br>");

        return reified;
    }

    function positionCursor($root) {
        var cursor = $root[0].querySelector(".cursor");
        if (cursor) {
            var range = document.createRange();
            var sel   = window.getSelection();

            range.setStart(cursor, 0);
            range.collapse(true);

            sel.removeAllRanges();
            sel.addRange(range);
        }
    };

    return {
        restrict: 'A',
        template: require("./capture-template.html"),
        scope: {
            template: '=template'
        },

        controller: ['$scope', '$element', 'captureService', function($scope, $el, $$capture) {
            var context = {
                annotation: "google.com/blah"
            };

            $scope.template = parseTemplate($scope.template.template, context);
            $scope.doCreate = function() {
                var editor = $el[0].querySelector('.editor');
                $$capture.post(editor.innerText)
                    .then(function() {
                        console.log('done!');
                    });;
            };
        }],

        link: function(scope, el, attrs) {
            var editor = angular.element(el[0].querySelector('.editor'));
            editor.attr("contenteditable", true);

            // give the template time to render
            $timeout(function() {
                positionCursor(editor);
            }, 0);
        }
    };
}];
