import React from 'react';
import { storiesOf, action } from '@kadira/storybook';
import ROverlay from '../index.coffee';


class OverlayWrapper extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
		this.state.visible = false;
		this.toggle = this.toggle.bind(this);
		this.close = this.close.bind(this);
	}

	toggle() {
		this.setState({visible: !this.state.visible})
	}

	close() {
		this.setState({visible: false})
	}

	render() {
		return (
			<div>
				<span>Press 'open' to open the overlay</span>
				<button onClick={this.toggle} >open</button>

		  		<ROverlay visible={this.state.visible} onClose={this.close}>
		  			<div>
		  				<h1>This content is inside overlay</h1>
		    			<p>blablabla</p>
		    			{this.props.children}
		    		</div>
		    	</ROverlay>
	    	</div>
	 		)
		}	
}

storiesOf('ROverlay', module)
  .add('Basic open and close', () => (
  	<OverlayWrapper/>
  ))
  .add('Multiple overlays', () => (
    <OverlayWrapper>
    	<div>
    		<h2>Overlay inside overlay</h2>
    		<OverlayWrapper/>
    	</div>
    </OverlayWrapper>
  ));