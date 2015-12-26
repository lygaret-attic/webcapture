const REQUEST_START    = 'state/meta/REQUEST_START';
const REQUEST_COMPLETE = 'state/meta/REQUEST_COMPLETE';

function initialState() {
    return { active: 0 };
}

export default function reducer(state = initialState(), action = {}) {
    const { active } = state;
    switch (action.type) {
    case REQUEST_START:
        return { ...state, active: active + 1 };
    case REQUEST_COMPLETE:
        return { ...state, active: active - 1 };
    default:
        return state;
    }
};


export function request(dispatch, url, options = {}) {
    const dispatchComplete = (resp) => {
        dispatch({ type: REQUEST_COMPLETE, url, error: null });
        return resp;
    };

    const dispatchError = (error) => {
        dispatch({ type: REQUEST_COMPLETE, url, error });
        throw error;
    };

    dispatch({ type: REQUEST_START, url });
    return window.fetch(url, options).then(dispatchComplete, dispatchError);
}
