"use strict";

import * as io from './io';
import wormhole from './autoio';
import {get_config} from 'libconfig';
import {is_absolute, is_current_origin, is_wormhole_origin} from './utils';

var CS = get_config('CS');

var add_remote_origin = (url) => CS.DEFAULT_ORIGIN + '/remote' + url;

function genIOfunc(method) {
    return function (url, ...args) {
        if (!is_absolute(url)) {
            throw new Error("New autoio api supports only absolute urls");
        }
        if (is_current_origin(url)) {
            return io[method](url, ...args);
        } else if (is_wormhole_origin(url)) {
            return wormhole[method](url, ...args);
        } else {
            throw new Error("Can't make request on " + url);
        }
    };
}

class AutoIO {
    constructor() {
        this.GET = genIOfunc('GET');
        this.POST = genIOfunc('POST');
        this.PUT = genIOfunc('PUT');
        this.DELETE = genIOfunc('DELETE');
        this.REMOTE = {
            GET: (url, ...args) => this.GET(add_remote_origin(url), ...args),
            POST: (url, ...args) => this.POST(add_remote_origin(url), ...args),
            PUT: (url, ...args) => this.PUT(add_remote_origin(url), ...args),
            DELETE: (url, ...args) => this.DELETE(add_remote_origin(url), ...args)
        };
    }
}

export default new AutoIO();
