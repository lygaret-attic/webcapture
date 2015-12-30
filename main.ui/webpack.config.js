var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

var nodeModulesPath = path.resolve(__dirname, 'node_modules');
var reactMinPath    = path.resolve(nodeModulesPath, 'react/dist/react.js');

module.exports = {
    devtool: 'eval',
    entry  : [
        'webpack-hot-middleware/client',
        path.join(__dirname, 'app/index.js')
    ],
    output: {
        path: path.join(__dirname, 'dist'),
        filename: '[name].js',
        publicPath: '/'
    },
    resolve: {
        alias: {
            'app'      : path.resolve(__dirname, 'app'),
            'react/lib': path.resolve(nodeModulesPath, 'react/lib'),
            'react'    : reactMinPath
        }
    },
    plugins: [
        new HtmlWebpackPlugin({
            template: 'app/index.html',
            inject  : 'body',
            filename: 'index.html'
        }),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoErrorsPlugin(),
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify('development')
        })
    ],
    module: {
        noParse: [reactMinPath],
        loaders: [{
            test: /\.jsx?$/,
            exclude: /node_modules/,
            loaders: ['react-hot', 'babel?cacheDirectory']
        }, {
            test: /\.scss$/,
            exclude: /node_modules/,
            loaders: ['style', 'css?modules&localIdentName=[name]--[local]--[hash:base64:5]', 'sass']
        }, {
            test: /\.html$/,
            exclude: /node_modules/,
            loaders: ['raw']
        }]
    }
};
