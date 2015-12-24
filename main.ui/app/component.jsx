import React from 'react';

export default class Hello extends React.Component {

    constructor(props) {
        super(props);
        this.state = { count: 0 };
    }

    incrementCount(event) {
        this.setState({ count: this.state.count + 1 });
    }

    render() {
        return (
            <h1 onClick={this.incrementCount.bind(this)}>
              Click to Update: {this.state.count}
            </h1>
        );
    }

}
