TYPE = 'cookie'
sl = require 'service-locator'
$ = require 'jquery'
{get_config} = require 'libconfig'
{is_foreign_origin} = require './utils'
_AppState = window.AppState # FIXME
{put_to_wh_ready_queue} = require './queue'


module.exports = if is_foreign_origin()
    get: (name, success_callback, error_callback) ->
        payload =
            name: name
            op: 'get'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    set: (name, value, expires, success_callback, error_callback) ->
        payload =
            name: name
            value: value
            expires: expires
            op: 'set'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    remove: (name, success_callback, error_callback) ->
        payload =
            name: name
            op: 'remove'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    observe: -> throw 'not implemented yet'
else
    get: (name, success_callback, error_callback) ->
        setTimeout(
            -> success_callback ($.cookie name)
            0
        )

    set: (name, value, expires, success_callback, error_callback) ->
        setTimeout(
            -> success_callback (
                $.cookie(name, value,
                    expires: expires
                    domain: get_config 'CS.COOKIE_DOMAIN*'
                    path: '/'
                )
            )
            0
        )

    remove: (name, success_callback, error_callback) ->
        setTimeout(
            -> success_callback (
                $.removeCookie(name,
                    domain: get_config 'CS.COOKIE_DOMAIN*'
                    path: '/'
                )
            )
            0
        )

    observe: -> throw 'not implemented yet'
