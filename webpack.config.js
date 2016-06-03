var path = require('path');
var webpack = require('webpack');
var prod = process.argv.indexOf('-p') >= 0;

module.exports = {
    entry: './src/index_webpack.js',
    output: {
        path: __dirname,
        filename: 'dist/msa.js'
    },
    module: {
        loaders: [
            {   test: /\.js?$/,
                loader: 'babel-loader'
            },
            { test: /\.css$/,
                loader: "style-loader!css-loader" }
        ],
    },
    devtool: 'source-map',
    plugins: [
        new webpack.DefinePlugin({
            MSA_VERSION: JSON.stringify(require("./package.json").version)
        }),
    ],
    // require other ES6 files (experimental)
    resolve: {
      root: path.resolve(__dirname),
      alias: {
        "bio.io": 'node_modules/bio.io/src/index'
      }
    },
};
var w = module.exports;

// only executed with -p
if(prod) {
    w.plugins.push(
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                collapse_vars: true
            },
        sourceMap: true
    }));
    var WebpackStrip = require('strip-loader');
    w.module.loaders.push(
        {   test: path.join(__dirname, 'src'),
         loader: WebpackStrip.loader('console.log') }
    );
}
