var path = require('path');
module.exports = {
    entry: './src/index.js',
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
            }
        ]
    },
    devtool: 'source-map'
};
