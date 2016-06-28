const path = require('path');

module.exports = {
  resolve: {
    root: path.resolve(__dirname, '../../../node_modules'),
	modulesDirectories: [path.resolve(__dirname, '../modules/')]
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
      {
        test: /\.sass$/,
        loaders: ["style", "css", "sass"]
      },
      {
        test: /\.css?$/,
        loaders: [ 'style', 'raw' ],
        include: path.resolve(__dirname, '../')
      }
    ]
  }
}