const INCREMENT = 'store/counter/INCREMENT';

export default function reducer(state = { count: 0 }, action = {}) {
    switch(action.type) {
    case INCREMENT:
        const {count} = state;
        return { count: count + action.incr, ...state };
    default:
        return state;
    }
}

export function increment(incr = 1) {
    return { type: INCREMENT, incr };
}
