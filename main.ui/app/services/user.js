/* service for managing the current user, fetching their profile, and authentication. */

import { network } from 'app/services/network';

const PROFILE_INIT           = 'services/user/PROFILE_INIT';
const PROFILE_SUCCESS        = 'services/user/PROFILE_SUCCESS';
const PROFILE_FAILURE        = 'services/user/PROFILE_FAILURE';

const AUTHENTICATION_INIT    = 'services/user/AUTHENTICATION_INIT';
const AUTHENTICATION_SUCCESS = 'services/user/AUTHENTICATION_SUCCESS';
const AUTHENTICATION_FAILURE = 'services/user/AUTHENTICATION_FAILURE';

function initialState() {
    return {
        user         : null,
        authorization: null,
        active       : false,
        error        : null
    };
}

export default function reduce(state = initialState(), action = {}) {
    switch(action.type) {
    case PROFILE_INIT:
    case AUTHENTICATION_INIT:
        return { ...state, active: true };

    case PROFILE_SUCCESS:
        return { ...state, active: false, user: action.user, error: null };

    case PROFILE_FAILURE:
        return { ...state, active: false, user: null, error: action.error };

    case AUTHENTICATION_SUCCESS:
        return { ...state, active: false, authorization: action.authorization, error: null };

    case AUTHENTICATION_FAILURE:
        return { ...state, active: false, authorization: null, error: action.error };

    default:
        return state;
    };
}

export function authenticate(store, email, password) {
    return (dispatch) => {
        dispatch({ type: AUTHENTICATION_INIT });

        const creds   = `${email.value}:${password.value}`;
        const hash    = window.btoa(creds);

        network(store, '/api/v1/user/token', {
            method : 'POST',
            headers: {
                'content-type': 'application/json',
                'authorization': `Basic ${hash}`
            },
            body   : JSON.stringify({ scopes: ['any'] })
        })
            .catch(resp => dispatch({ type: AUTHENTICATION_FAILURE, error: resp }))
            .then (resp => resp.text())
            .then (token => dispatch({ type: AUTHENTICATION_SUCCESS, authorization: token }));
    };
}
