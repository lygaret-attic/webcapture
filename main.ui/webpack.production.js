var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var StatsPlugin = require('stats-webpack-plugin');

module.exports = {
    entry  : [
        path.join(__dirname, 'app/index.js')
    ],
    output: {
        path: path.join(__dirname, 'dist'),
        filename: '[name].js?[hash]',
        publicPath: '/'
    },
    plugins: [
        new webpack.optimize.OccurenceOrderPlugin(),
        new ExtractTextPlugin('[name].css?[hash]', { allChunks: true }),
        new HtmlWebpackPlugin({
            template: 'app/index.html',
            inject  : 'body',
            filename: 'index.html'
        }),
        new webpack.optimize.UglifyJsPlugin({
            compressor: {
                warnings: false,
                screw_ie8: true
            }
        }),
        new StatsPlugin('webpack.stats.json'),
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
        })
    ],
    module: {
        loaders: [{
            test: /\.jsx?$/,
            exclude: /node_modules/,
            loader: 'babel'
        }, {
            test: /\.scss$/,
            exclude: /node_modules/,
            loader: ExtractTextPlugin.extract('style', 'css?modules&localIdentName=[name]--[local]--[hash:base64:5]!sass')
        }, {
            test: /\.html$/,
            exclude: /node_modules/,
            loaders: ['raw']
        }]
    }
};
