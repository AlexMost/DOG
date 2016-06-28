l = require 'lodash'

get_react_root_node_id = (component) ->
    (component._reactInternalInstance or component)._rootNodeID

make_overlay_manager = ->
    overlays_order = []
    overlays_map = {}

    recalc_zindex = ->
        return if l.isEmpty overlays_map

        minZIndex = (l.min overlays_map, (comp) -> comp.state.zindex)?.state.zindex or 1
        currentMinIndex = minZIndex
        for ov_id in overlays_order
            overlays_map[ov_id].setState {zindex: currentMinIndex}
            currentMinIndex += 1

    open_overlay: (component) ->
        id = get_react_root_node_id component
        if id of overlays_map
            overlays_order = (overlays_order.filter (o_id) -> o_id isnt id).concat [id]
        else
            overlays_map[id] = component
            overlays_order.push(id)

        recalc_zindex()

    dispose_overlay: (component) ->
        id = get_react_root_node_id component
        overlays_order = (overlays_order.filter (o_id) -> o_id isnt id)
        recalc_zindex()
        delete overlays_map[id]

    get_overlays_count: -> l.size overlays_order


# singleton overlay manager for global scope
# later may be some different overlay managers on the page if needed.
overlay_manager = make_overlay_manager()

module.exports = {
    overlay_manager
    make_overlay_manager
}
