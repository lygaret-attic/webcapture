import { request } from './meta';

// user has been successfully authenticated
const AUTH_SUCCESS = 'store/user/AUTH_SUCCESS';
const AUTH_FAILURE = 'store/user/AUTH_FAILURE';

// TODO look up initial state in cookies/localStorage
function initialState() {
    return {
        isAuthenticated: false,
        error          : null,
        user           : null
    };
}

export default function reducer(state = initialState(), action = {}) {
    switch(action.type) {
    case AUTH_SUCCESS:
        return { ...state, isAuthenticated: true, user: action.user, error: null };
    case AUTH_FAILURE:
        return { ...state, isAuthenticated: false, user: null, error: action.error };
    default:
        return state;
    }
}

export function fetchUser() {
    return function fetchUser(dispatch) {

        let field   = 'demo@example.com:supersecret';
        let headers = {
            'Authorization': `Basic ${window.btoa(field)}`
        };

        return request(dispatch, '/api/v1/user.json', { headers })
            .then((response) => {
                if (!response.ok) {
                    throw "Couldn't fetch user";
                }

                return response.json();
            })
            .then((json) => dispatch({ type: AUTH_SUCCESS, user: json }))
            .catch((error) => dispatch({ type: AUTH_FAILURE, error: error }));
    };
}
