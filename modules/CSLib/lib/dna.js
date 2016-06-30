import {data_to_opts, partial} from 'libprotein';

function simpleBind(initApp, appName, optsName) {
    let extract_opts = partial(data_to_opts, optsName);
    let protocol = [
        ['*cons*', [], {concerns: {before: [extract_opts]}}]
    ];

    function Impl(node, opts) {
        initApp(node, opts);
        return {};
    }

    var protocols = {definitions: {}, implementations: {}};
    protocols.definitions[appName] = protocol;
    protocols.implementations[appName] = Impl;

    return {protocols}
}

export default {simpleBind: simpleBind};
