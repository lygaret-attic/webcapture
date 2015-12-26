import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { Router, Route } from 'react-router';
import { createHistory } from 'history';
import { syncReduxAndRouter } from 'redux-simple-router';
import createStore from './store';

require("./index.scss");

const store   = createStore({});
const history = createHistory();
syncReduxAndRouter(history, store);

import Login from './ui/login.jsx';
import Dashboard from './ui/dashboard.jsx';

const root  = ReactDOM.render(
    <Provider store={store}>
      <Router history={history}>
        <Route path="/login" component={Login} />
        <Route path="/" component={Dashboard} />
      </Router>
    </Provider>,
    document.getElementById("root")
);

if (module.hot) {
    let injection = require('react-hot-loader/Injection').RootInstanceProvider;
    injection.injectProvider({
        getRootInstances: function() {
            return [root];
        }
    });
}
