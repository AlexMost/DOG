import { getDomain, getFirstLevelDomain } from '../app/lib/domain';

describe('Test getDomain', () => {
    it('should return domain', () => {
        expect(getDomain(false, 'supersumka.com.ua')).toBe('com.ua');
    });
    it('should return capitalized domain', () => {
        expect(getDomain(true, 'supersumka.com.ua')).toBe('Com.ua');
    });
});

describe('Test getFirstLevelDomain', () => {
    it('should return first level domain', () => {
        expect(getFirstLevelDomain('supersumka.com.ua')).toBe('com.ua');
    });
});
