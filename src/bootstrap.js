import React from 'react';
import ReactDOM from 'react-dom';
import { Router, Route, Link, browserHistory, IndexRoute} from 'react-router'
import App from './App'

import SearchPage from './search-page.jsx';
import ComponentPage from './component-page.jsx';


ReactDOM.render((
  <Router history={browserHistory}>
    <Route path="/" component={App}>
      <IndexRoute component={SearchPage}/>
      <Route path="/comp" component={ComponentPage}>
        <Route path="/comp/:compName" component={ComponentPage}/>
      </Route>
    </Route>
  </Router>
), document.getElementById('content'))