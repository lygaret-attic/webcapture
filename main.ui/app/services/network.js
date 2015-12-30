/* service for writing/reading from the network.
   automatically handle adding authentication headers, etc. */

import { AUTHENTICATION_SUCCESS, AUTHENTICATION_FAILURE } from 'app/services/user';

const REQUEST_INIT    = 'services/network/REQUEST_INIT';
const REQUEST_SUCCESS = 'services/network/REQUEST_SUCCESS';
const REQUEST_FAILURE = 'services/network/REQUEST_FAILURE';

function initialState() {
    return {
        active: 0,
        authorization: false
    };
}

export default function reducer(state = initialState(), action = {}) {
    const { active } = state;

    switch(action.type) {
    case REQUEST_INIT:
        return { ...state, active: active + 1 };
    case REQUEST_SUCCESS:
    case REQUEST_FAILURE:
        return { ...state, active: active - 1 };
    case AUTHENTICATION_SUCCESS:
        return { ...state, authorization: action.authorization };
    case AUTHENTICATION_FAILURE:
        return { ...state, authorization: null };
    default:
        return state;
    }
};

export function network(store, url, options = {}) {
    // add auth token if it's in localStorage
    let {network:{authorization}} = store.getState();
    if (authorization) {
        options.headers = options.headers || {};
        options.headers['Authorization'] = options.headers['Authorization'] || `Token ${authorization}`;
    }

    // proxy to fetch directly
    store.dispatch({ type: REQUEST_INIT, url, options });
    return window.fetch(url, options)
        .then((response)  => {
            if (response.ok) {
                store.dispatch({ type: REQUEST_SUCCESS, response });
                return response;
            }
            throw response;
        })
        .catch((response) => {
            store.dispatch({ type: REQUEST_FAILURE, response });
            throw response;
        });
}
