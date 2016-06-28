build:
	node_modules/.bin/babel-node --presets react,es2015 dog-build.js
	node_modules/.bin/webpack --config ./src/webpack.config.js

serve:
	devd -o out

watch:
	node_modules/.bin/webpack --config ./src/webpack.config.js -w