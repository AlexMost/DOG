# TODO require 'jquery'
$ = require 'jquery'
{add_prefix} = require './utils'

EXPECTED_CONTENT_TYPE = 'json'
SENT_CONTENT_TYPE = 'application/json; charset=utf-8'

IO =
    type: 'direct'

    GET: (url, success_cb, error_cb, options, data) ->
        options or= {}

        $.ajax(
            add_prefix(url),
            {
                type: 'GET'
                dataType: options.dataType or EXPECTED_CONTENT_TYPE
                data: data
                contentType: options.contentType or SENT_CONTENT_TYPE
                success: success_cb or undefined
                error: error_cb or undefined
                complete: options.complete
                async: if options.async is false then false else true
            })

    POST: (url, data, success_cb, error_cb, options) ->
        options or= {}

        $.ajax(
            add_prefix(url),
            {
                type: 'POST'
                dataType: options.dataType or EXPECTED_CONTENT_TYPE
                contentType: if options.contentType is false then false else options.contentType or SENT_CONTENT_TYPE
                processData: if options.processData is false then false else true
                data: data
                success: success_cb or undefined
                error: error_cb or undefined
                complete: options.complete
                async: if options.async is false then false else true
                traditional: if options.traditional then true else false
            })

    PUT: (url, data, success_cb, error_cb, options) ->
        options or= {}

        $.ajax(
            add_prefix(url),
            {
                type: 'PUT'
                dataType: options.dataType or EXPECTED_CONTENT_TYPE
                contentType: options.contentType or SENT_CONTENT_TYPE
                data: data
                success: success_cb or undefined
                error: error_cb or undefined
                complete: options.complete
                async: if options.async is false then false else true
            })

    DELETE: (url, data, success_cb, error_cb, options) ->
        options or= {}

        $.ajax(
            add_prefix(url),
            {
                type: 'DELETE'
                dataType: options.dataType or EXPECTED_CONTENT_TYPE
                contentType: options.contentType or SENT_CONTENT_TYPE
                data: data
                success: success_cb or undefined
                error: error_cb or undefined
                complete: options.complete
                async: if options.async is false then false else true
            })

IO.get = IO.GET
IO.put = IO.PUT
IO.post = IO.POST
IO.delete = IO.DELETE
        
module.exports = IO
