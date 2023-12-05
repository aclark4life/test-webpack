const path = require('path');

module.exports = {
  entry: './src/index.js', // Entry point of your application
  output: {
    filename: 'bundle.js', // Output file name
    path: path.resolve(__dirname, 'dist'), // Output directory
  },
  mode: 'development', // Set the mode to 'development' or 'production'
  devServer: {
    contentBase: './dist', // Serve files from the 'dist' directory
    port: 8080, // Specify a port for the development server
  },
};
