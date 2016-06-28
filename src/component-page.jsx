import React from 'react';
import docMap from '../out/docs-map.json';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';

class ComponentPage extends React.Component {
	constructor(props) {
		super(props);
		this.component = docMap[this.props.params.compName];
		this.handleSelect = this.handleSelect.bind(this);
	}

	handleSelect(tab) {
		console.log('selected tab ' + tab);
	}

	render() {
		return (
			<div>
				<h1>{this.component.name}</h1>
				<h3>{this.component.description.join(' ')}</h3>
				 <Tabs
        			onSelect={this.handleSelect}
        			selectedIndex={0}
      				>
      				<TabList>
      					<Tab>
							Readme
					    </Tab>
				    </TabList>
				    <TabPanel>
				    	<iframe 
				    		src={`/components/${this.component.name}/README.md.html`}
				    		frameBorder="0"
				    		height="100%"
				    		width="100%"/>
			    	</TabPanel>
			    </Tabs>
			</div>
			)
	}
}

export default ComponentPage;