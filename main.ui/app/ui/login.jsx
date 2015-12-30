import React from 'react';
import { connect } from 'react-redux';
import { IndexLink } from 'react-router';

import store from 'app/services/store';
import { authenticate } from 'app/services/user';

class Login extends React.Component {

    login(dispatch) {
        const {email, password} = this.refs;
        dispatch(authenticate(store, email, password));
    }

    render() {
        const {dispatch} = this.props;
        return (
            <div>
              <input type="text" ref="email" placeholder="me@example.com" />
              <input type="password" ref="password" placeholder="supers3cret" />
              <button type="submit" onClick={this.login.bind(this, dispatch)}>Login</button>
            </div>
        );
    }
}

function discriminate(state) {
    return { state };
}

export default connect(discriminate)(Login);
