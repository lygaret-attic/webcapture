export function deepFreeze(o) {
    Object.freeze(o);
    for (let key in o) {
        let freeze = o.hasOwnProperty(key)
                && o[key] !== null
                && (typeof(o[key]) === "object" || typeof o[key] === "function")
                && !Object.isFrozen(o[key]);

        if (freeze) {
            deepFreeze(o[key]);
        }
    }

    return o;
}
