{get_global_stream} = require 'libstream'
l = require 'lodash'
$ = require "jquery"


[viewportContainer, viewportKey] = do ->
    container = window
    key = 'inner'
    if not 'innerWidth' in window
        key = 'client'
        container = document.documentElement or document.body
    [container, key]


viewport = ->
    width: viewportContainer[viewportKey + 'Width']
    height: viewportContainer[viewportKey + 'Height']


isVisible = ($elemOffsetDocument, pageCoords) ->
    $elemOffset =
        left: $elemOffsetDocument.left - pageCoords.pageX,
        top: $elemOffsetDocument.top - pageCoords.pageY

    if $elemOffset.left < 0 or $elemOffset.top < 0
        # elem is left of or above viewport
        return false

    vp = viewport()
    if $elemOffset.left > vp.width or $elemOffset.top > vp.height
        # elem is below or right of vp
        return false

    return true

getElementVisibilityChangeStream = ($node) ->
    nodeOffset = $node.offset()

    (get_global_stream 'DOMStream')
        .filter ({type}) -> type is 'scroll'
        .map -> {pageX: window.pageXOffset, pageY: window.pageYOffset}
        .map l.partial(isVisible, nodeOffset)

isElementVisible = ($node) ->
    isVisible $node.offset(), {pageX: window.pageXOffset, pageY: window.pageYOffset}


isElementPartInViewport = (node) ->
    node = node[0] or node
    # Check if any of node parts are visible in current viewport
    rect = node.getBoundingClientRect()
    vp = viewport()

    if (
        (rect.top < 0 and rect.bottom < 0) or                   # elem above VP
        (rect.top > vp.height and rect.bottom > vp.height) or   # elem below VP
        (rect.left < 0 and rect.right < 0) or                   # elem left fo VP
        (rect.left > vp.width and rect.right > vp.width)        # elem right of VP
    )
        return false
    return true

getElementPartViewportChangeStream = (node) ->

    (get_global_stream 'DOMStream')
    .filter ({type}) -> type in ['resize', 'scroll']
    .map -> isElementPartInViewport node

fits_to_block = (X_i_0, Y_i_0, X_i_1, Y_i_1, X_o_0, Y_o_0, X_o_1, Y_o_1) ->
    ###
          X_o_0
      Y_o_0 +--------------------------------------------+
            |                 Outer block                |
            |                                            |
            |           X_i_0                            |
            |     Y_i_0  ______________________          |
            |           |                     |          |
            |           |     Inner block     |          |
            |           |                     |          |
            |           |_____________________|X_i_1     |
            |                               Y_i_1        |
            |                                            |
            +--------------------------------------------+ X_o_1
                                                       Y_o_1
    ###
    if X_o_0 < X_i_0 < X_o_1 and Y_o_0 < Y_i_0 < Y_o_1 and X_o_0 < X_i_1 < X_o_1 and Y_o_0 < Y_i_1 < Y_o_1
        true
    else
        false

fits_to_viewport = (X_i_0, Y_i_0, X_i_1, Y_i_1) ->
    vp = viewport()
    fits_to_block X_i_0, Y_i_0, X_i_1, Y_i_1, 0, 0, vp.width, vp.height

isElementBelowViewport = (element) ->
    $window = $(window)
    $window.height() + $window.scrollTop() <= $(element).offset().top

isElementCompletelyVisible = (element) ->
    element = element[0] or element
    {top, bottom} = element.getBoundingClientRect()
    top >= 0 and bottom <= window.innerHeight

isElementAboveViewport = (element) ->
    element = element[0] or element
    {top, bottom} = element.getBoundingClientRect()
    top < 0 and bottom < 0

getElementAboveViewportStream = (node) ->
    (get_global_stream 'DOMStream')
    .filter ({type}) -> type in ['resize', 'scroll']
    .map -> isElementAboveViewport node

getElementOffset = (node) ->
    box = node.getBoundingClientRect()

    body = document.body
    docEl = document.documentElement

    scrollTop = window.pageYOffset || docEl.scrollTop || body.scrollTop
    scrollLeft = window.pageXOffset || docEl.scrollLeft || body.scrollLeft

    clientTop = docEl.clientTop || body.clientTop || 0
    clientLeft = docEl.clientLeft || body.clientLeft || 0

    top  = box.top + scrollTop - clientTop
    left = box.left + scrollLeft - clientLeft

    {top, left}

module.exports = {
    getElementVisibilityChangeStream,
    isElementVisible,
    isElementPartInViewport,
    getElementPartViewportChangeStream,
    isElementBelowViewport,
    isElementCompletelyVisible,
    fits_to_block,
    fits_to_viewport,
    isElementAboveViewport,
    getElementAboveViewportStream,
    getElementOffset
}
