import { createStore as _cs, combineReducers } from 'redux';
import counter from './counter';

const reducers = combineReducers({
    counter
});

export default function createStore(state) {
    return _cs(reducers, state);
}
