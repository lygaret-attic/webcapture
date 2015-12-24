import React from 'react';
import { render } from 'react-dom';
import { Provider } from 'react-redux';
import createStore from './store';

import Root from './root.jsx';

const store = createStore({ counter: 0 });
const root  = React.render(
    <Provider store={store}>
      <Root />
    </Provider>, document.getElementById("root"));

if (module.hot) {
    let injection = require('react-hot-loader/Injection').RootInstanceProvider;
    injection.injectProvider({
        getRootInstances: function() {
            return [root];
        }
    });
}
