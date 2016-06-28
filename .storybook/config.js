import { configure } from '@kadira/storybook';

function loadStories() {
  require('../modules/ROverlay/stories/story');
}

configure(loadStories, module);