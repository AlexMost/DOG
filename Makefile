build:
	node_modules/.bin/babel-node --presets react,es2015 dog-build.js
	node_modules/.bin/webpack --config ./src/webpack.config.js
	node ./node_modules/.bin/build-storybook --config-dir modules/ROverlay/.storybook --output-dir out/components/ROverlay/storybook
	node_modules/.bin/codo --output out/components/ROverlay/codo modules/ROverlay

serve:
	devd -o out

watch:
	node_modules/.bin/webpack --config ./src/webpack.config.js -w