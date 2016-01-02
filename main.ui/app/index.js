import _       from 'lodash';
import angular from 'angular';
import 'angular-ui-router';

const app = angular.module('webcapture', ['ui.router']);
export default app;

// install services

import error from './services/error';
error(app);

import token from './services/token';
token(app);

import auth from './services/auth';
auth(app);

import http from './services/http';
http(app);

import templates from './services/templates';
templates(app);

// router controller

import root from './states/root';
root(app);

// configure routing and login-fallback

import {addRoutes as loginRoutes} from './states/login';
import {addRoutes as captureRoutes} from './states/capture';

app.config(['$stateProvider', '$urlRouterProvider', ($stateP ,  $urlRouterP) => {
    $urlRouterP.otherwise('/');

    // login has no url (only accessible through auth failure)
    loginRoutes($stateP, { name: 'login' });
    captureRoutes($stateP, { name: 'capture', root: '' });

    console.log($stateP);
}]);
