import l from 'lodash';
import React from 'react';
import ReactDOM from 'react-dom';
import classSet from 'classnames';

/**
 *
 * Mobile Overlay component
 *
 * This component will hide your page content while overlay is opened.
 *
 * Usage example:
 *
 * import {MobileOverlay as Overlay} from 'ROverlay/mobile_overlay';
 *
 * const MyExampleComponent = React.createClass({
 *     render: function () {
 *         return (
 *             <div className="your_component_wrapper_class">
 *                 <Overlay
 *                     open={this.props.isOverlayOpen}
 *                     pageContentNodeClassName={'b-main_page_content_wrapper'}
 *                 >
 *                     <Overlay.Header onCloseCallback={this.onOverlayClose}>
 *                         {'header markup'}
 *                     <Overlay.Header>
 *
 *                     <Overlay.Body>
 *                         {'body markup'}
 *                     <Overlay.Body>
 *
 *                     <Overlay.Footer>
 *                         {'footer markup'}
 *                     <Overlay.Footer>
 *
 *                 </Overlay>
 *             </div>
 *         );
 *     }
 * });
 *
 * P.S.
 *
 * Default page content node selector is: '.b-cms'
 *
 * */

const Header = ({children, onCloseCallback}) => {
    children = typeof children === 'string' ? React.createElement('span', {}, children) : children;
    return (
        <div className="b-m-overlay__header">
            <div className="b-m-overlay__header-text">
                {children}
            </div>
            <div
                className="b-m-overlay__close-btn"
                onClick={onCloseCallback}
            >
            </div>
        </div>
    );
};

const Body = ({children, addCls}) => {
    children = typeof children === 'string' ? React.createElement('span', {}, children) : children;
    let overlayClasses = classSet(addCls, "b-m-overlay__body-content");

    return (
        <div className="b-m-overlay__body">
            <div  className={classSet(overlayClasses)}>
                {children}
            </div>
        </div>
    );
};

const Footer = ({children}) => {
    children = typeof children === 'string' ? React.createElement('span', {}, children) : children;
    return (
        <div className="b-m-overlay__footer">
            {children}
        </div>
    );
};

export const MobileOverlay = React.createClass({

    getInitialState: function () {
        let mountNode = document.createElement('div');
        document.body.appendChild(mountNode);
        return {
            mountNode: mountNode,
            pageContentNode: document.querySelector(this.props.pageContentNodeClassName)
        };
    },

    getDefaultProps: function () {
        return {
            pageContentNodeClassName: '.b-cms'
        };
    },

    renderOverlay: function () {
        if (this.scrollTop == null) {
            this.scrollTop = $(window).scrollTop();
        }
        $(this.state.pageContentNode).addClass('b-hidden');
        ReactDOM.render(
            <MountNode
                children={this.props.children}
                onCloseCallback={this.props.onCloseCallback}
            />,
            this.state.mountNode
        );
    },

    unmountOverlay: function () {
        this.props.onCloseCallback && this.props.onCloseCallback();
        let wasMounted = ReactDOM.unmountComponentAtNode(this.state.mountNode);
        if (wasMounted) {
            $(this.state.pageContentNode).removeClass('b-hidden');
            $(window).scrollTop(this.scrollTop);
            this.scrollTop = null;
        }
    },

    componentDidMount: function () {
        this.scrollTop = null;
        if (this.props.open) {
            this.renderOverlay();
        }
    },

    componentDidUpdate: function () {
        if (this.props.open) {
            this.renderOverlay();
        } else {
            this.unmountOverlay();
        }
    },

    componentWillUnmount: function () {
        this.unmountOverlay();
    },

    render: function () {
        return null;
    }
});

const MountNode = ({children}) => {
    return (
        <div className="b-m-overlay">
            {children}
        </div>
    );
};

MobileOverlay.Header = Header;
MobileOverlay.Body = Body;
MobileOverlay.Footer = Footer;
