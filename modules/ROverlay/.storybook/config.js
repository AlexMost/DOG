import { configure } from '@kadira/storybook';

function loadStories() {
  require('../stories/story');
}

configure(loadStories, module);