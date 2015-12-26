import React from 'react';
import ReactDOM from 'react-dom';

import { Provider } from 'react-redux';
import { Router, Route } from 'react-router';
import { createHistory } from 'history';
import { syncReduxAndRouter } from 'redux-simple-router';
import createStore from './store';
import Root from './root.jsx';

require("./index.scss");

const store   = createStore({});
const history = createHistory();

syncReduxAndRouter(history, store);

const root  = React.render(
    <Provider store={store}>
      <Router history={history}>
        <Route path="/" component={Root}/>
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
