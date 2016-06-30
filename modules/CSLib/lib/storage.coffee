TYPE = 'storage'
{get_config, set_config} = require 'libconfig'
{put_to_wh_ready_queue} = require './queue'
{is_foreign_origin} = require './utils'
sl = require 'service-locator'
Rx = require "rx"
l = require 'lodash'
require 'baselib/store.js'

_AppState = window.AppState # FIXME

# TODO make storage and io polymorphic discoverable services

storage = if is_foreign_origin()
    get: (ns, key, success_callback, error_callback) ->
        payload =
            ns: ns
            key: key
            method: 'get'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    set: (ns, key, value, success_callback, error_callback) ->
        payload =
            ns: ns
            key: key
            value: value
            method: 'set'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    remove: (ns, key, success_callback, error_callback) ->
        payload =
            ns: ns
            key: key
            method: 'remove'
            _type: TYPE

        put_to_wh_ready_queue ->
            whc = sl.locate 'WormholeClient', _AppState
            whc.postMessage payload, success_callback, error_callback

    observe: -> throw new Error 'not implemented yet'

else
    get: (ns, key, success_callback=(l.noop), error_callback) ->
        store = new Store ns
        # looks like Store never returns errors
        # it just returns undefined if found value is null (the key is absent
        # from localStorage) and null if it can't JSON.parse found value
        setTimeout(
            -> success_callback (store.get key)
            0
        )


    set: (ns, key, value, success_callback=(l.noop), error_callback) ->
        store = new Store ns
        setTimeout(
            -> success_callback (store.set key, value)
            0
        )


    remove: (ns, key, success_callback=(l.noop), error_callback) ->
        store = new Store ns
        setTimeout(
            -> success_callback (store.remove key)
            0
        )


    observe: -> throw new Error 'not implemented yet'

ok = (observer, result) ->
    observer.onNext result
    observer.onCompleted()

nok = (observer, err) ->
    observer.onError err
    #observer.onCompleted() # never gonna be called

rstorage =
    get: (ns, key) ->
        Rx.Observable.create (observer) ->
            storage.get ns, key, (l.partial ok, observer), (l.partial nok, observer)

    set: (ns, key, value) ->
        Rx.Observable.create (observer) ->
            storage.set ns, key, value, (l.partial ok, observer), (l.partial nok, observer)

    remove: (ns, key) ->
        Rx.Observable.create (observer) ->
            storage.remove ns, key, (l.partial ok, observer), (l.partial nok, observer)


USER_DATA_STORAGE_NS = "user_data"
USER_DATA_STORAGE_KEY = "user_info"

user_data_storage =
    get: (cb) -> storage.get USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY, cb
    set: (value, cb) -> storage.set USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY, value, cb
    remove: (cb) -> storage.remove USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY, cb

user_data_rstorage =
    get: -> rstorage.get USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY
    set: (value) -> rstorage.set USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY, value
    remove: -> rstorage.remove USER_DATA_STORAGE_NS, USER_DATA_STORAGE_KEY


module.exports =
    storage: storage
    user_data_storage: user_data_storage
    rstorage: rstorage
    user_data_rstorage: user_data_rstorage
