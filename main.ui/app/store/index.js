import { createStore as _cs, combineReducers, compose, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

import counter from './counter';
import routing from './routing';
import meta    from './meta';
import user    from './user';

const hasDevtools = !!(window && window.devToolsExtension);

export default function createStore(state) {
    const finalCreateStore = compose(
        applyMiddleware(thunk),
        hasDevtools ? window.devToolsExtension() : f => f
    )(_cs);

    const reducers = combineReducers({
        routing,
        counter,
        user,
        meta
    });

    return finalCreateStore(reducers, state);
}
