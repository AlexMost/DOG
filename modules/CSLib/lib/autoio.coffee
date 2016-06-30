{get_config, set_config } = require 'libconfig'
{is_foreign_origin, add_prefix} = require './utils'
{put_to_wh_ready_queue} = require './queue'
sl = require 'service-locator'
{emitter} = require 'event-channel'
io = require "./io"

_AppState = window.AppState # TODO pass this explicitly

TRANSPORT_TYPE = 'Wormhole'
TYPE = 'io'

# TODO make storage and io polymorphic discoverable services
module.exports = if is_foreign_origin()
    WH = sl.locate 'Wormhole', _AppState

    if WH
        WH.Client

    else
        WH =
            Client:
                GET: (url, success_callback, error_callback, options, data) ->
                    payload =
                        method: 'GET'
                        data: data
                        url: add_prefix(url)
                        options: options
                        _type: TYPE

                    put_to_wh_ready_queue ->
                        whc = sl.locate 'WormholeClient', _AppState
                        whc.postMessage payload, success_callback, error_callback

                POST: (url, data, success_callback, error_callback, options) ->
                    payload =
                        method: 'POST'
                        data: data
                        url: add_prefix(url)
                        options: options
                        _type: TYPE

                    put_to_wh_ready_queue ->
                        whc = sl.locate 'WormholeClient', _AppState
                        whc.postMessage payload, success_callback, error_callback

                PUT: (url, data, success_callback, error_callback, options) ->
                    payload =
                        method: 'PUT'
                        data: data
                        url: add_prefix(url)
                        options: options
                        _type: TYPE

                    put_to_wh_ready_queue ->
                        whc = sl.locate 'WormholeClient', _AppState
                        whc.postMessage payload, success_callback, error_callback

                DELETE: (url, data, success_callback, error_callback, options) ->
                    payload =
                        method: 'DELETE'
                        data: data
                        url: add_prefix(url)
                        options: options
                        _type: TYPE

                    put_to_wh_ready_queue ->
                        whc = sl.locate 'WormholeClient', _AppState
                        whc.postMessage payload, success_callback, error_callback

                type: TRANSPORT_TYPE


            on_ready: do ->
                WH_READY = false
                WORMHOLE_STATUS_SERVER_READY = 'wormhole_server_ready'
                queue = []

                emitter.sub(
                    WORMHOLE_STATUS_SERVER_READY,
                    ->
                        WH_READY = true
                        queue.map (f) -> f()
                        queue = []
                )

                (cb) ->
                    if WH_READY
                        cb()
                    else
                        queue.push(cb)

        sl.provide({name: 'Wormhole', instance: WH, singleton: true}, _AppState)

        WH.Client.post = WH.Client.POST

        WH.Client
else
    io
