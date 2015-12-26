import React from 'react';
import { connect } from 'react-redux';
import * as counter from './store/counter';

class App extends React.Component {

    incrementCount(dispatch, event) {
        const action = counter.increment(1);
        dispatch(action);
    }

    render() {
        const {dispatch, counter} = this.props;
        return (
            <h1 onClick={this.incrementCount.bind(this, dispatch)}>
              Click to Increment: {counter.count}
            </h1>
        );
    }

}

function subbedState(state) {
    return {
        counter: state.counter
    };
}

export default connect(subbedState)(App);
