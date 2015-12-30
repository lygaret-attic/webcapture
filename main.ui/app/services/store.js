import { createStore, combineReducers, compose, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

const initialState = {};

import routing from 'app/services/routing';
import network from 'app/services/network';
import user    from 'app/services/user';

const reducers     = combineReducers({ routing, network, user });

const hasDevtools  = !!(window && window.devToolsExtension);
const store        = compose(
    applyMiddleware(thunk),
    hasDevtools ? window.devToolsExtension() : (x => x)
)(createStore)(reducers, initialState);

export default store;
