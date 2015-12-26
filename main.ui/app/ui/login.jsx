import React from 'react';
import { connect } from 'react-redux';
import { IndexLink } from 'react-router';

class Login extends React.Component {
    render() {
        const {dispatch} = this.props;
        return (
            <h1>Login
              <IndexLink to="/">dashboard</IndexLink>
            </h1>
        );
    }
}

function discriminate(state) {
    return {};
}

export default connect(discriminate)(Login);
