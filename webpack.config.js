var path = require('path');
var webpack = require('webpack');

module.exports = {
    devtool: 'source-map',
    entry: path.join(__dirname, 'web'),
    output: {
        path: path.join(__dirname, 'public'),
        filename: 'bundle.js'
    },
    devServer: {
        contentBase: path.join(__dirname, 'public'),

        historyApiFallback: true,
        progress: true,
        proxy: {
            "/api/*": "http://localhost:3000"
        },

        stats: 'errors-only',
        host: process.env.HOST || 'localhost',
        port: process.env.PORT || 3001
    },
    plugins: [
    ],
    module: {
        loaders: [{
            test: /\.js$/,
            loaders: ['babel'],
            exclude: /node_modules/,
            include: __dirname
        }, {
            test: /\.scss$/,
            loaders: ['style', 'css', 'sass'],
            exclude: /node_modules/,
            include: __dirname
        }, {
            test: /\.html$/,
            loaders: ['raw'],
            exclude: /node_modules/,
            include: __dirname
        }, {
            test: /\.json$/,
            loaders: ['json'],
            exclude: /node_modules/,
            include: __dirname
        }]
    },
    sassLoader: {
        includePaths: [path.resolve(__dirname, "./web/sass")]
    }
};
