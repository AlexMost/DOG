{is_foreign_origin} = require './utils'
{emitter} = require 'event-channel'
{info} = (require 'console-logger').ns 'wh_ready_queue'

# FIXME
_AppState = window.AppState
WORMHOLE_STATUS_SERVER_READY = 'wormhole_server_ready'

# FIXME
_AppState.wh_ready_queue or= []
queue = _AppState.wh_ready_queue

emitter.sub(
    WORMHOLE_STATUS_SERVER_READY,
    -> (f AppState) while (f = queue.shift())
)

put_to_wh_ready_queue = (cb) ->
    if is_foreign_origin()
        if _AppState.WORMHOLE_READY
            cb()
        else
            # FIXME
            queue.push cb
    else
        info "Not a foreign origin!"
        cb()


module.exports = {put_to_wh_ready_queue}