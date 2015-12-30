import { request } from 'app/store/meta';

// user has been successfully authenticated
const AUTH_SUCCESS = 'store/user/AUTH_SUCCESS';
const AUTH_FAILURE = 'store/user/AUTH_FAILURE';

function initialState() {
    return {
        isFetching     : false,
        isAuthenticated: false,
        user           : null
    };
}

export default function reducer(state = initialState(), action = {}) {
    switch(action.type) {
    case FETCH_REQUEST:
        return { ...state, isFetching: true , error: null, user: null };
    case FETCH_SUCCESS:
        return { ...state, isFetching: false, error: null, user: action.user };
    case FETCH_FAILURE:
        return { ...state, isFetching: false, error: action.error, user: null };
    case AUTH_SUCCESS:
        return { ...state, isAuthenticated: true };
    case AUTH_FAILURE:
        return { ...state, isAuthenticated: false };
    default:
        return state;
    }
}

export function fetchUser() {
    return function fetchUser(dispatch) {
        dispatch({ type: FETCH_REQUEST });

        let field  = 'demo@example.com:supersecret';
        let hash   = window.btoa(field);

        fetch('/api/v1/user.json', { headers: {'Authorization': `Basic ${hash}` }})
            .then((response) => {
                if (response.status !== 200) {
                    throw "Couldn't fetch user";
                }

                return response.json();
            })
            .then((json) => {
                dispatch({ type: FETCH_SUCCESS, user: json });
                dispatch({ type: AUTH_SUCCESS });
            })
            .catch((error) => {
                dispatch({ type: FETCH_FAILURE, error });
                dispatch({ type: AUTH_FAILURE });
            });
    };
}

/***/

function readToken() {
    return localStorage.getItem('auth_token');
}

function saveToken(token) {
    return localStorage.setItem('auth_token', token);
}

function clearToken() {
    return localStorage.removeItem('auth_token');
}

function fetchProfile(token) {
    return request('/api/v1/user.json')
        .then((resp) => {
            if (resp.ok) { return resp.json(); }
            throw `Couldn't fetch user, status: ${resp.status}`;
        });
}

function requestToken(email, password, scopes = ["any"]) {
    let creds = `${email}:${password}`;
    let hash  = window.btoa(field);

    return request('/api/v1/user/token', {
        method : 'POST',
        headers: { 'Authentication': 'Basic ${hash}' }
    }).then((resp) => {
        if (resp.ok) {
            let token = resp.text();
            return saveToken(token);
        }

        throw `Couldn't request token, status: ${resp.status}`;
    });
}
