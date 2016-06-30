_AppState = window.AppState # FIXME
{is_foreign_origin} = require './lib/utils'
{storage, rstorage, user_data_storage, user_data_rstorage} = require './lib/storage'
#wc = require 'Wormhole/WormholeClient'
{get_config} = require 'libconfig'
sl = require 'service-locator'

## TODO make storage and io polymorphic discoverable services
#if is_foreign_origin()
#    whc = sl.locate 'WormholeClient', _AppState
#    unless whc
#        sl.provide({
#            name: 'WormholeClient',
#            instance: new wc.Client,
#            singleton: true
#        }, _AppState)


module.exports =
    IO: require './lib/io'
    rio: require './lib/rio'
    RIO: require './lib/rio'
    AUTOIO: require './lib/autoio'
    autoio: require './lib/autoio'
    AUTOIO2: require('./lib/autoio2').default
    uuid: require('./lib/uuid.js').default
    utils: require './lib/utils'
    pluralize: require './lib/pluralize'
    custom_widgets: require './lib/custom_widgets'
    validation: require './lib/validation'
    storage: storage
    rstorage: rstorage
    user_data_storage: user_data_storage
    user_data_rstorage: user_data_rstorage
    XDMCookieStorage: require './lib/xcookie'
    queue: require './lib/queue'
    keyCode: require './lib/keycodes'
    viewport: require './lib/viewport'
    charCode: require('./lib/charcodes.js').default
    dna: require('./lib/dna.js').default
