import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { fetchUser } from '../store/user';

class Dashboard extends React.Component {
    render() {
        const {dispatch}  = this.props;
        const doFetchUser = () => dispatch(fetchUser());

        return (
            <div>
              { this.props.authFetching ? <span>loading...</span> : null }
              { this.props.auth         ? <span>Welcome!...</span> : null }
              <h1>{this.props.user && this.props.user.email}</h1>
              <Link to="/login">Login</Link>
              <a onClick={doFetchUser}>Fetch User</a>
            </div>
        );
    }
};

function subbedState(state) {
    return {
        auth: state.user.isAuthenticated,
        authFetching: state.user.isFetching,
        authError: state.user.error,
        user: state.user.user
    };
}

export default connect(subbedState)(Dashboard);
