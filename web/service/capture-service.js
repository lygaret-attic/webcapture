module.exports = function captureSerivceProvider() {
    var endpoint = '/api/v1';
    this.setEndpoint = function(ep) {
        endpoint = ep;
    };

    function CaptureService($http) {
        this.$http    = $http;
        this.endpoint = endpoint;
    }

    CaptureService.prototype.post = function(content) {
        var data = {capture: { content }};
        return this.$http.post(this.endpoint + '/captures', data);
    };

    this.$get = ['$http', function($http) {
        return new CaptureService($http);
    }];
};
