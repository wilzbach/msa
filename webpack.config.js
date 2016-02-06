var path = require('path');
module.exports = {
    entry: './src/index_webpack.js',
    output: {
        path: __dirname,
        filename: 'dist/msa.js'
    },
    module: {
        loaders: [
            {   test: path.join(__dirname, 'src'),
                loader: 'babel-loader',
                query: {
                    presets: 'es2015',
                },
            },
            { test: /\.css$/,
                loader: "style-loader!css-loader" }
        ],
    },
    devtool: 'source-map'
};
