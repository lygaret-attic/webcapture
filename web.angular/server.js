var path = require('path');
var express = require('express');
var proxy = require('dev-rest-proxy');
var webpack = require('webpack');
var webpackMiddleware = require('webpack-dev-middleware');
var webpackHotMiddleware = require('webpack-hot-middleware');

var config = require('./webpack.config.js');
var port   = process.env.PORT || 3001;
var app    = express();

var is_production = process.env.NODE_ENV === "production";

// proxy requests to the rails app
app.all('/api', function(req, res) {
    proxy(req, res, 'localhost', 3000);
});

// in production mode, serve from the dest folder 
// (for testing the optimized build)
if (process.env.NODE_ENV === "production") {
    app.use(express.static(config.output.path));

    // history fallback
    app.get('*', function response(req, res) {
        res.sendFile(path.join(config.output.path, 'index.html'));
    });
}

// otherwise, serve with the dev middleware
// hot reloading would be cool, but it's never worked for me, so sorry hot middleware...
else {
    var compiler   = webpack(config);
    var middleware = webpackMiddleware(compiler, {
        publicPath: config.output.publicPath,
        contentBase: 'app',
        stats: {
            colors: true,
            hash: false,
            timings: true,
            chunks: true,
            chunkModules: false,
            modules: false
        }
    });

    app.use(middleware);
    app.use(webpackHotMiddleware(compiler));
    app.get('*', function response(req, res) {
        res.write(middleware.fileSystem.readFileSync(path.join(config.output.path, 'index.html')));
        res.end();
    });
}

app.listen(port, '127.0.0.1', function onStart(err) {
    if (err) { console.log(err); }
    console.info("-> listening at http://localhost:%s", port);
});
