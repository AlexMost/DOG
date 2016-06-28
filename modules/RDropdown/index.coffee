
{info, warn, error, debug} = require('console-logger').ns "RChosen"
{data_to_opts, partial, pubsubhub, is_array} = require 'libprotein'
React = require 'react'
ReactDOM = require 'react-dom'

extract_opts = partial data_to_opts, 'rdd'
RDropdownComponent = require './component'

RDropdown = React.createFactory RDropdownComponent

protocol = [
    ['*cons*',       [], {concerns: {before: [extract_opts, pubsubhub]}}]
    ['on_select', ['h']]
    ['set_value', ['value']]
    ['disable', []]
    ['enable', []]
]

RDropdownWrapper = React.createClass
    getInitialState: ->
        value: @props.value
        disabled: @props.disabled

    render: ->
        RDropdown
            options: @props.options
            value: @state.value
            placeholder: @props.placeholder
            fixedSelectedText: @props.fixedSelectedText
            name: @props.name
            disabled: @state.disabled
            onSelect: (option) =>
                @props.onSelect option
                @setState {value: option.value}

impl = (node, opts, {pub, sub}) ->

    Component = React.createElement(
        RDropdownWrapper,
        options: opts.Opts
        value: opts.Value
        placeholder: opts.Placeholder
        fixedSelectedText: opts.Fixedselectedtext
        name: opts.Name
        disabled: opts.Disabled
        onSelect: (option) -> pub 'on_select', option)

    dd = ReactDOM.render(
        Component
        if node.length then node[0] else node
    )

    on_select: (h)-> sub 'on_select', h

    set_value: (value) ->
        dd.setState {value}

    disable: () ->
        dd.setState {disabled: true}

    enable: () ->
        dd.setState {disabled: false}

module.exports =
    protocols:
        definitions:
            RDropdown: protocol
        implementations:
            RDropdown: impl
    component: RDropdownComponent
