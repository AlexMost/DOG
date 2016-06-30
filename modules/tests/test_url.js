import { getParamByname, addGetParam } from '../app/lib/url';

describe('Test getParamByName', () => {
    it('should return param if exist', () => {
        expect(getParamByname('param1',
            'http://supersumka.com.ua/?param1=1')).toBe('1');
    });
    it('should return empty string if not exist', () => {
        expect(getParamByname('param2',
            'http://supersumka.com.ua/?param1=1')).toBe('');
    });
});

describe('Test addGetParam', () => {
    it('should add param aftetr ?', () => {
        expect(addGetParam('http://some.com', 'key', 'val'))
            .toBe('http://some.com?key=val');
    });

    it('should add param aftetr &', () => {
        expect(addGetParam('http://some.com?key1=val1', 'key', 'val'))
            .toBe('http://some.com?key1=val1&key=val');
    });
});
