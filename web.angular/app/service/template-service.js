module.exports = function templateSerivceProvider() {
    var endpoint = '/api/v1';
    this.setEndpoint = function(ep) {
        endpoint = ep;
    };

    class TemplateService {
        constructor($http) {
            this.$http = $http;
            this.endpoint = `${endpoint}/templates`;
        }

        list() {
            return this.$http.get(this.endpoint).then((resp) => resp.data);
        }

        get(key) {
            return this.$http.get(`${this.endpoint}/${key}`).then((resp) => resp.data);
        }
    }

    this.$get = ['$http', function($http) {
        return new TemplateService($http);
    }];
};
