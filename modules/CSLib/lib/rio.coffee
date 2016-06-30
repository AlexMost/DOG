{GET, PUT, POST, DELETE, type} = require './autoio'
Rx = require "rx"
l = require 'lodash'

## which promiseProxy to use?
#promiseProxy = (resolve, reject) -> (data) ->
#    if not data?.status or "#{data?.status}".toLowerCase() in ['success', 'ok']
#        resolve.apply(null, arguments)
#    else
#        reject.apply(null, arguments)

promiseProxy = (ok, nok) -> (data, httpCode) ->

    status = data?.status and "#{data?.status}".toLowerCase()

    if status in ['success', 'ok'] then ok data, httpCode

    else if status and status is 'error'
        nok data, httpCode

    else if not status and l.isNumber data
        ok data, 200

    else if (l.isObject data) and (not data.status) and (httpCode in [200, 'success']) then ok data, 200

    else if (l.isArray data) and (httpCode in [200, 'success']) then ok data, 200

    else if httpCode not in [200, 'success']
        nok data, httpCode

    else if l.isString data?.responseText
        resp = try
            JSON.parse data.responseText
        catch
            data

        ok resp, httpCode
    else
        ok data, httpCode

onDispose = l.noop

ok_ = (observer, result) ->
    observer.onNext result
    observer.onCompleted()

nok_ = (observer, err) ->
    observer.onError err
    #observer.onCompleted() # never gonna be called


RIO =
    type: type + "/RIO"

    GET: (url, data, options) ->
        Rx.Observable.create (observer) ->
            h = promiseProxy (l.partial ok_, observer), (l.partial nok_, observer)
            GET url, h, h, options, data
            onDispose

    POST: (url, data, options) ->
        Rx.Observable.create (observer) ->
            h = promiseProxy (l.partial ok_, observer), (l.partial nok_, observer)
            POST url, data, h, h, options
            onDispose

    PUT: (url, data, options) ->
        Rx.Observable.create (observer) ->
            h = promiseProxy (l.partial ok_, observer), (l.partial nok_, observer)
            PUT url, data, h, h, options
            onDispose

    DELETE: (url, data, options) ->
        Rx.Observable.create (observer) ->
            h = promiseProxy (l.partial ok_, observer), (l.partial nok_, observer)
            DELETE url, data, h, h, options
            onDispose

    GET_: (url, data, options) ->
        Rx.Observable.create (observer) ->
            GET url, (l.partial ok_, observer), (l.partial nok_, observer), options, data
            onDispose

    POST_: (url, data, options) ->
        Rx.Observable.create (observer) ->
            POST url, data, (l.partial ok_, observer), (l.partial nok_, observer), options
            onDispose

    PUT_: (url, data, options) ->
        Rx.Observable.create (observer) ->
            PUT url, data, (l.partial ok_, observer), (l.partial nok_, observer), options
            onDispose

    DELETE_: (url, data, options) ->
        Rx.Observable.create (observer) ->
            DELETE url, data, (l.partial ok_, observer), (l.partial nok_, observer), options
            onDispose

RIO.post = RIO.POST
RIO.get = RIO.GET
RIO.delete = RIO.DELETE
module.exports = RIO
