build:
	node_modules/.bin/babel-node --presets react,es2015 dog-build.js
	node_modules/.bin/webpack --config ./src/webpack.config.js
	node ./node_modules/.bin/build-storybook --config-dir modules/ROverlay/.storybook --output-dir out/components/ROverlay/storybook
	node_modules/.bin/codo --output out/components/ROverlay/codo modules/ROverlay
	node_modules/.bin/documentation build modules/CSLib/lib/url.js -f html -o out/components/CSLib/codo

dev:
	node_modules/.bin/webpack-dev-server --config ./src/webpack.config.js --content-base ./out --history-api-fallback --hot --inline

watch:
	node_modules/.bin/webpack --config ./src/webpack.config.js -w