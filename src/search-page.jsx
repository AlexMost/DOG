import React from 'react';
import index from '../out/index.json';
import docMap from '../out/docs-map.json';
import Autocomplete from 'react-autocomplete';
import lunr from 'lunr';

window.index = index;
window.docMap = docMap;
window.idx = lunr.Index.load(index);

class SearchPage extends React.Component {
	constructor(props) {
		super(props);
		this.index = index;
		this.docMap = docMap;
		this.state = {};
		this.state.value = '';
		this.state.items = [];
	}

	render() {
		const { title, index } = this.props;
		return (
			<div>
				<h1>DOG</h1>
				<h2>Search for component</h2>
				<Autocomplete
					value={this.state.value}
					items={this.state.items}
					getItemValue={(item) => item.name}
					onSelect={value => this.setState({ value })}
		  	        onChange={(event, value) => {
		  	        	this.setState({ value });
			            const idxresult = idx.search(value);
			            const items = idxresult.map(({ref}) => docMap[ref]);
			            this.setState({ items });
			        }}
                  renderItem={(item, isHighlighted) => (
		            <div
		              style={{background: isHighlighted ? '#a6ec9d' : 'white'}}
		              key={item.id}
		              id={item.id}
		            >
		            	<div>
		            		{item.name}
	            		</div>
	            		<div>
	            			{item.keywords.join(',')}
	            		</div>
	            		<div>
	            			{item.description}
	            		</div>
	            	</div>
          		  	)}
				/>
			</div>
		)	
	}
}

export default SearchPage