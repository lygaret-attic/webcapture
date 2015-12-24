import React from 'react';
import { connect } from 'react-redux';
import * as counter from './store/counter';

class App extends React.Component {

    render() {
        const {dispatch, count} = this.props;
        debugger;

        return (
            <h1 onClick={() => dispatch(counter.increment(1))}>
              Click to Increment: {count}
            </h1>
        );
    }

}

function select(state) {
    return {
        count: state.counter
    };
}

export default connect(select)(App);
