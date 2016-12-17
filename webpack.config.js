var path = require('path')
var webpack = require('webpack')

module.exports = {
  entry: './src/zxing.js',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'zxing.js',
    library: 'Zxing',
    libraryTarget: 'umd'
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /(node_modules|src\/zxing-module\.js)/,
        loader: 'babel-loader'
      }
    ]
  },
  node: {
    fs: 'empty'
  }
}
