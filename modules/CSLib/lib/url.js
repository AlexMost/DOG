// @flow
/**
  returns url GET parameter where the key is `name`
  @example:
     http://www.my_site.com?param_1=value_1&param_2=value_2
     value = getParamByname('param_2')
     value is 'value_2'
 */
export function getParamByname(paramName: string, url: string = location.search) : string {
    const name = paramName.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    const regexS = `[\\?&]${name}=([^&#]*)`;
    const regex = new RegExp(regexS);
    const results = regex.exec(url);
    if (results) {
        return decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
    return '';
}

/**
  Adds parameter to url
*/
export function addGetParam(url: string, key: string, value: string): string {
    const param = value ? `${key}=${value}` : key;
    const paramSeparator = url.indexOf('?') !== -1 ? '&' : '?';
    return `${url}${paramSeparator}${param}`;
}
