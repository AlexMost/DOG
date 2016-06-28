React = require 'react'
{div, span, input, i, ul, li} = React.DOM
l = require 'lodash'
{CloseOnOutsideClick} = require 'ReactMixins'
classNames = require 'classnames'

default_item_view = (item) -> item.text
default_placeholder_view = (item, selected_text, cls) ->
    span
        className: cls
        selected_text


RDropdown = React.createClass
    displayName: "RDropdown"

    mixins: [CloseOnOutsideClick]

    propTypes:
        options: React.PropTypes.array.isRequired
        placeholder: React.PropTypes.string
        value: React.PropTypes.any
        valuePropName: React.PropTypes.string
        name: React.PropTypes.string
        onSelect: React.PropTypes.func.isRequired
        onOpen: React.PropTypes.func
        onClose: React.PropTypes.func
        immutable: React.PropTypes.bool
        disabled: React.PropTypes.bool
        isOpen: React.PropTypes.bool
        maxHeight: React.PropTypes.number
        itemView: React.PropTypes.func
        placeholderView: React.PropTypes.func
        addCls: React.PropTypes.string
        showPlaceholderOnEmptyOptVal: React.PropTypes.bool
        showSelectedInList: React.PropTypes.bool
        fixedSelectedText: React.PropTypes.string

    getDefaultProps: ->
        onDisabledSelect: ->
        onSelect: ->
        onOpen: ->
        onClose: ->
        immutable: false
        showPlaceholderOnEmptyOptVal: false
        showSelectedInList: false
        addCls: ""
        valuePropName: "value"
        listCls: ""

    getInitialState: ->
        value: @props.value
        options: @props.options
        name: @props.name
        isOpen: @props.isOpen or false

    toggle: (ev) ->
        if @props.disabled and not @state.isOpen
            @props.onDisabledSelect?()
            return
        @setState({isOpen: not @state.isOpen}, if @state.isOpen then @props.onClose)
        ev.stopPropagation()

    getSelected: ->
        currentValue = @props.value?.toString()
        l.find(@props.options, (o) => o[@props.valuePropName]?.toString() is currentValue)

    itemClick: (ev, option) ->
        if @props.immutable
            @props.onSelect option, ev
        else
            @setState {isOpen: false}, => @props.onSelect option, ev

    getSelectedItemText: (selected) ->
        if @props.fixedSelectedText
            return @props.fixedSelectedText

        selected_text = if @props.showPlaceholderOnEmptyOptVal and not selected?[@props.valuePropName]
            @props.placeholder
        else
            ((selected and (@props.itemView or default_item_view)(selected)) or @props.placeholder)

        (@props.placeholderView or default_placeholder_view)(
            selected, selected_text, @props.valueCls)

    getOptionsToRender: () ->
        l.reject(@props.options, (o) =>
            not @props.showSelectedInList and o[@props.valuePropName] is @props.value)

    render: ->
        selected = @getSelected()
        list_style = {}

        if @props.maxHeight and @state.isOpen
            list_style=
                overflow: "auto"
                display: "block"
                maxHeight: 430

        (div
            className: (classNames
                "b-drop-down": true
                "b-drop-down_state_active": @state.isOpen).concat(" #{@props.addCls}")

            onClick: @toggle
            (span
                className: classNames
                    "b-drop-down__value": true
                    "#{@props.valueWrapperCls}": !!@props.valueWrapperCls
                    "disabled": @props.disabled
                onClick: @props.onOpen
                @getSelectedItemText(selected)
            )
            (i
                className: "b-drop-down__arrow"
                onClick: @props.onOpen
            )
                (input
                    id: @props.name
                    name: @props.name
                    type: "hidden"
                    value: @props.value)
            (ul {className: "b-drop-down__list #{@props.listCls} js-dropdown", style: list_style},
                @getOptionsToRender().map (o) =>
                    (li
                        className: "b-drop-down__list-item"
                        key: o[@props.valuePropName] or "def-key"
                        onClick: (ev) =>
                            @itemClick ev, o
                        (@props.itemView or default_item_view)(o)
                    )
                if @props.lastItemView
                    li
                        className: "b-drop-down__list-item"
                        key: "last-item-view"
                        @props.lastItemView
            )
        )

module.exports = RDropdown
