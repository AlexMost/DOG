import React from 'react';
import index from '../out/index.json';
import docMap from '../out/docs-map.json';
window.index = index;
window.docMap = docMap;

class SearchPage extends React.Component {
	constructor(props) {
		super(props);
		this.index = index;
		this.docMap = docMap;
	}
	render() {
		const { title, index } = this.props;
		return (
			<div>
				<h1>DOG</h1>
				<h2>Search for component</h2>
				<input type="text"/>
			</div>
		)	
	}
}

export default SearchPage