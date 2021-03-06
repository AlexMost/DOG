{data_to_opts, partial, pubsubhub} = require 'libprotein'
React = require 'react'
ReactDOM = require 'react-dom'

extract_opts = partial data_to_opts, 'rchosen'
RChosen = React.createFactory(require './component')

protocol = [
    ['*cons*',       [], {concerns: {before: [extract_opts, pubsubhub]}}]
    ['on_select', ['h']]
]

impl = (node, opts, {pub, sub}) ->
    Component = RChosen
        options: opts.Opts
        value: opts.Value
        placeholder: opts.Placeholder
        fixedSelectedText: opts.Fixedselectedtext
        onSelect: (option) -> pub 'on_select', option

    ReactDOM.render(
        Component
        if node.length then node[0] else node
    )

    on_select: (h)-> sub 'on_select', h

module.exports =
    protocols:
        definitions:
            RChosen: protocol
        implementations:
            RChosen: impl

