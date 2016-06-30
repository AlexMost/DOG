import { capitalize } from 'lodash';

export function getFirstLevelDomain(hostName) {
    const splittedHost = hostName.split('.');
    if (splittedHost.length > 2) {
        return splittedHost.slice(1).join('.');
    }
    return hostName;
}

export function getDomain(capitalized, hostname = document.location.hostname) {
    const domain = getFirstLevelDomain(hostname);
    return capitalized ? capitalize(domain) : domain;
}
