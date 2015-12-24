module.exports = function captureSerivceProvider() {
    var endpoint = '/api/v1';
    this.setEndpoint = function(ep) {
        endpoint = ep;
    };

    class CaptureService {
        constructor($http) {
            this.$http = $http;
            this.endpoint = `${endpoint}/captures`;
        }

        post(content) {
            var data = {capture: {content}};
            return this.$http.post(this.endpoint, data);
        }
    }

    this.$get = ['$http', function($http) {
        return new CaptureService($http);
    }];
};
