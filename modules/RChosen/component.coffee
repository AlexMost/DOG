React = require 'react'
{div, span, input, i, ul, li} = React.DOM
classSet = require 'classnames'
{sortBy, union, map, escape} = require 'lodash'
$ = require 'jquery'
{CloseOnOutsideClick} = require 'ReactMixins'
{UP, DOWN, ENTER} = (require "CSLib").keyCode
l = require 'lodash'

controlKeys = [UP, DOWN, ENTER]

RChosen = React.createClass
    displayName: "RChosen"

    mixins: [CloseOnOutsideClick]

    propTypes:
        options: React.PropTypes.array.isRequired
        onSelect: React.PropTypes.func.isRequired
        lastItemView: React.PropTypes.any
        fixedSelectedText: React.PropTypes.string
        withoutSearchBar: React.PropTypes.bool

    getInitialState: ->
        value: @props.value
        options: @props.options
        name: @props.name
        isOpen: false
        current: 0
        filterValue: ""

    componentWillReceiveProps: (nextProps) ->
        if nextProps.value? or nextProps.forcedValueSync
            @setState
                value: nextProps.value

    toggle: (ev) ->
        @setState {isOpen: !@state.isOpen, filterValue: ""}, -> @refs.input.focus()
        ev.stopPropagation()


    getSelected: ->
        (@props.options.filter (o) =>
            l(o.value).toString() == l(@state.value?.value or @state.value).toString()
        )?[0]


    itemClick: (option) ->
        @setState {isOpen: false}, => @props.onSelect option


    inputFocus: (ev) -> ev.stopPropagation()


    getFilteredOptions: ->
        if @state.filterValue
            filterValue = @state.filterValue.toLowerCase()

#           These options were found by first characters in word
            first = @props.options.filter (o) =>
                o.text.toLowerCase().indexOf(filterValue) == 0

#           These options were found by characters from any position in the word
            other = @props.options.filter (o) =>
                o.text.toLowerCase().indexOf(filterValue) != -1

#           the result will be sorted alphabetically
            first = sortBy first, "text"
            other = sortBy other, "text"

            union first, other
        else
            @props.options


    saveFilter: (ev) -> @setState {filterValue: ev.target.value, current: 0}

    itemUp: ->
        if @state.current == 0
            @selectItem @getFilteredOptions().length - 1, false
        else
            @selectItem @state.current - 1, false

    itemDown: ->
        if @state.current is @getFilteredOptions().length - 1
            @setState {current: 0}
            @selectItem 0, false
        else
            @selectItem @state.current + 1, false


    handleControlKey: (ev) ->
        return unless @state.isOpen
        ev.preventDefault()

        switch ev.keyCode
            when UP
                @itemUp()
            when DOWN
                @itemDown()
            when ENTER
                @selectItem @state.current


    handleKeyDown: (ev) ->
        if ev.keyCode in controlKeys
            @handleControlKey ev


    selectItem: (index, hide=true) -> # selecting only by index
        item = @getFilteredOptions()[index]
        if item
            @props.onSelect item if hide
            @setState {value: item, current: index}, =>
                @scrollToSelected( @state.current - index > 0 )
        @setState {isOpen:false} if hide

    scrollToSelected: ->
        @refs.parent.scrollTop = @refs.current.offsetTop;

    highlightSearchTerm: ( text ) ->
        return "" if not text
        regexp = new RegExp @state.filterValue, "i"

        if @state.filterValue
            arr = text.split regexp
            span {},
                arr.length > 1 and arr[0] or ""
                span className: "h-bg-yellow", text.match(regexp)[0]
                arr.length > 1 and arr[1] or ""
        else
            text

    getSelectedItemText: ->
        if @props.fixedSelectedText
            @props.fixedSelectedText
        else
            @getSelected()?.text or @props.placeholder

    render: ->
        openCls = if @state.isOpen then "b-drop-down_state_active" else ""
        options = @getFilteredOptions()

        (div
            className: "b-drop-down #{openCls} #{@props.wrapperCls or ''}"
            onClick: @toggle
            (span
                className: "b-drop-down__value #{@props.valueCls or ''}"
                @getSelectedItemText())
            (i {className: "b-drop-down__arrow"})
                (input
                    id: @props.name
                    name: @props.name
                    type: "hidden"
                    value: @props.value)
            (div {className: "b-drop-down__dropped"},
                (div {className: classSet({
                        "b-drop-down__search": true,
                        "h-hidden": @props.withoutSearchBar
                    })},
                    (div {className: "b-input"},
                        (input
                            ref: "input"
                            className: "b-input__field b-input__field_height_small"
                            type: "text"
                            autoComplete: "off"
                            onClick: @inputFocus
                            onChange: @saveFilter
                            onKeyDown: @handleKeyDown
                            value: @state.filterValue
                        )
                    )
                )
                (ul
                    ref: 'parent'
                    className: "b-drop-down__list js-dropdown"
                    style:
                        maxHeight: "300px"
                    for opt, index in options
                        do (opt, index) =>
                            (li
                                ref: if index is @state.current then 'current' else "listItem#{index}"
                                className: classSet
                                    "b-drop-down__list-item": true
                                    "h-bold": opt?.bold or false
                                    "b-drop-down__list-item_state_hover": index is @state.current
                                key: "#{index}#{opt}"
                                onClick: (ev) =>
                                    ev.preventDefault()
                                    @selectItem index
                                @highlightSearchTerm(opt.text)
                            )
                    if @props.lastItemView
                        (li
                            className: classSet
                                "b-drop-down__list-item": true
                            key: "last-item-view"
                            @props.lastItemView

                        )
                )
            )
        )


module.exports = RChosen
