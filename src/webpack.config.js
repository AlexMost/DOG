const path = require('path');

module.exports = {
    entry: {app: [path.resolve(__dirname, "./bootstrap.js")]},
    output: {
        path: path.resolve(__dirname, '../out'),
        publicPath: "/assets/",
        filename: "bootstrap.js"
    },
    module: {
        loaders: [
            { test: /\.jsx?$/, 
              exclude: /node_modules/, 
              loader: 'babel-loader',
              query: {
                presets: ['es2015', 'react']
              },
            },
            {
              test: /\.sass$/,
              loaders: ["style", "css", "sass"]
            },
            { test: /\.json/, loader: 'json-loader'},
        ]
    }
};