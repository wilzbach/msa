var path = require('path');
var webpack = require('webpack');
module.exports = {
    entry: './src/index_webpack.js',
    output: {
        path: __dirname,
        filename: 'dist/msa.js'
    },
    module: {
        loaders: [
            {   test: path.join(__dirname, 'src'),
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
        })
    ]
};
