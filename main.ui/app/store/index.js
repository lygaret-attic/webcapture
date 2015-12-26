import { createStore as _cs, combineReducers, compose, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

import counter from './counter';
import routing from './routing';

const hasDevtools = !!(window && window.devToolsExtension);

export default function createStore(state) {
    const finalCreateStore = compose(
        applyMiddleware(thunk),
        hasDevtools ? window.devToolsExtension() : f => f
    )(_cs);

    const reducers = combineReducers({
        routing,
        counter
    });

    return finalCreateStore(reducers, state);
}
