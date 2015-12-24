module.exports = function hotkeySerivceProvider() {

    class HotkeyService {
        constructor($rootScope) {
            this.registered = {};
            this.current    = this.registered;
            this.currentStr = "";
        }

        reset() {
            this.current = this.registered;
            this.currentStr = "";
        }

        /* sequence should be C-x C-c m, etc.*/
        register(sequence, action) {
            let chords  = sequence.split(' ');
            let current = this.registered;

            for (let [index, chord] of chords.entries()) {
                let [key, ...mods] = chord.split('-').reverse();

                current[key] = current[key] || [];
                let registration = current[key].find((reg) => reg_modstr_p(reg, mods));
                if (registration == null) {
                    registration   = {
                        ctrl  : mods.indexOf("C") >= 0,
                        meta  : mods.indexOf("M") >= 0,
                        shift : mods.indexOf("S") >= 0,
                        action: index === (chords.length - 1) ? action : null,
                        descendants: {}
                    };

                    current[key].push(registration);
                }

                current = registration.descendants;
            }
        }

        accept(e) {
            // skip modifiers, etc.
            if (e.which < 48) { return; }

            let key  = String.fromCharCode(e.which).toLowerCase();
            let regs = this.current[key];
            let reg  = regs && regs.find((reg) => reg_event_p(reg, e));

            if (reg && reg.action) {
                this.reset();
                return reg.action;
            }
            else if (reg) {
                this.current = reg.descendants;
                this.currentStr += ` ${key}`;
            }
            else {
                this.reset();
            }

            return null;
        }
    }

    function reg_modstr_p(reg, modstrs) {
        return ((reg.ctrl && modstrs.indexOf("C") >= 0) || (!reg.ctrl && modstrs.indexOf("C") < 0)) &&
               ((reg.meta && modstrs.indexOf("M") >= 0) || (!reg.meta && modstrs.indexOf("M") < 0));
    }

    function reg_event_p(reg, e) {
        return ((reg.ctrl && e.ctrlKey) || (!reg.ctrl && !e.ctrlKey)) &&
               ((reg.meta && e.metaKey) || (!reg.meta && !e.metaKey));
    }

    this.$get = function($rootScope) {
        return new HotkeyService($rootScope);
    };
};
