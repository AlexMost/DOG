import uuid from 'uuid';

export default () => {
    return uuid.v4().toUpperCase();
};
