import React from 'react';
import { Provider } from 'react-redux';
import { Router, Route } from 'react-router';
import { syncReduxAndRouter } from 'redux-simple-router';

import "./index.scss";

import history     from './history';
import store       from './services/store';
import { network } from './services/network';

import Login     from './ui/login.jsx';
import Dashboard from './ui/dashboard.jsx';

boot();

function boot() {
    syncReduxAndRouter(history, store);

    const requireAuth = (nextState, replaceState, cb) =>
              network(store, '/api/v1/user.json')
              .then((resp) => {
                  if (!resp.ok) { throw resp; }
                  cb();
              })
              .catch((resp) => {
                  replaceState({ nextPathname: nextState.location.pathname }, "/login");
                  cb();
              });

    const root    = React.render(
        <Provider store={store}>
          <Router history={history}>
            <Route path="/"      component={Dashboard} onEnter={requireAuth} />
            <Route path="/login" component={Login} />
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
}
