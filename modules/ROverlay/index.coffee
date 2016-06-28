{createClass, DOM: {div, span}} = React = require "react"
classSet = require 'classnames'
$ = require "jquery"
{overlay_manager} = require './overlay_manager.coffee'

require './css/b-react-overlay.sass'
require './css/b-react-overlay__dialog.sass'
require './css/layout.sass'

ESC = 27

# {get_global_stream} = require 'libstream'


module.exports = createClass
    displayName: "ROverlay"
    propTypes:
        visible: React.PropTypes.bool
        withoutCloseButton: React.PropTypes.bool
        withoutPadding: React.PropTypes.bool
        className: React.PropTypes.string
        children: React.PropTypes.any
        onScroll: React.PropTypes.func
        closeByButtonOnly: React.PropTypes.bool

    getInitialState: ->
        zindex: @props.zindex or 90000

    getDefaultProps: ->
        withoutPadding: false

    componentWillMount: ->
        @open() if @props.visible

        # (get_global_stream 'DOMStream')
        #     .filter ({type, keyCode}) -> type is 'keyup' and keyCode is ESC
        #     .filter => @props.visible
        #     .subscribe @close

    fixPositionBody: ->
        width = $("body").width()
        $("body").width(width).addClass("h-layout-hidden")
        $('#head_control_panel').width(width)

    unfixPositionBody: ->
        $("body").removeAttr("style").removeClass("h-layout-hidden")
        $("#head_control_panel").removeAttr("style")

    close: (extend_event) ->
        # Prevent double closing (can be closed by unmounting component)
        return if @closed

        # only if the last active overlay
        if overlay_manager.get_overlays_count() <= 1
            @unfixPositionBody()

        overlay_manager.dispose_overlay this
        @props.onClose?(extend_event)
        @closed = true

    open: ->
        @closed = false
        # only if the first active overlay
        if overlay_manager.get_overlays_count() == 0
            @fixPositionBody()

        overlay_manager.open_overlay this
        @props.onOpen?()

    componentWillUnmount: ->
        @close()

    shouldComponentUpdate: (nextProps) ->
        Boolean(nextProps.visible or @props.visible)

    componentWillReceiveProps: (newProps) ->
        if newProps.visible != @props.visible
            if newProps.visible then @open() else @close()

    onClickCloseButton: (extend_event) ->
        @props.onClose?(extend_event)

    onClickMask: (e) ->
        if not @props.closeByButtonOnly
            if @refs.mask is e.target
                @close {
                    button: 'mask'
                    event_args: e
                }

    onScrollMask: (e) -> @props.onScroll?(e)

    render: ->
        overlayClasses =
            "b-react-overlay__dialog": true
            "qa-np-department-popup": true
            "h-p-31": not @props.withoutPadding
        if @props.className
            overlayClasses[@props.className] = true
        if @props.classNameVisible
            overlayClasses[@props.classNameVisible] = @props.visible

        div
            className: classSet
                "b-react-overlay": true
                "h-hidden": not @props.visible
            onClick: @onClickMask
            onScroll: @onScrollMask
            style: {zIndex: @state.zindex}
            ref: "mask"
            div
                className: classSet(overlayClasses)
                if not @props.withoutCloseButton
                    span
                        className: "b-react-overlay__close-button qa-close-button"
                        onClick: (event_args) =>
                            @onClickCloseButton {
                                button: "x",
                                event_args
                            }
                        "×"
                @props.children
