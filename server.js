var WebpackDevServer = require('webpack-dev-server');
var webpack = require('webpack');
var config = require("./src/webpack.config.js");
config.entry.app.unshift("webpack-dev-server/client?http://localhost:8080/");
var compiler = webpack(config);
var server = new WebpackDevServer(compiler, {contentBase: './out', historyApiFallback: true, open: true});
server.listen(8080);