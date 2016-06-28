import React from 'react';
import docMap from '../out/docs-map.json';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import './style.sass';

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
        			selectedIndex={0}>
      				<TabList>
      					<Tab>
							Readme
					    </Tab>
					    <Tab>
					    	Try
					    </Tab>
					    <Tab>
					    	Doc
				    	</Tab>
				    </TabList>
				    <TabPanel>
				    	<iframe 
				    		src={`/components/${this.component.name}/README.md.html`}
				    		frameBorder="0"
				    		height="900px"
				    		width="100%"/>
			    	</TabPanel>
			    	<TabPanel>
			    		<iframe 
				    		src={`/components/${this.component.name}/storybook/index.html`}
				    		frameBorder="0"
				    		height="900px"
				    		width="100%"/>
			    	</TabPanel>
			    	<TabPanel>
			    		<iframe 
				    		src={`/components/${this.component.name}/codo/index.html`}
				    		frameBorder="0"
				    		height="900px"
				    		width="100%"/>
			    	</TabPanel>
			    </Tabs>
			</div>
			)
	}
}

export default ComponentPage;