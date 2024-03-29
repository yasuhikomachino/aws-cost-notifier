const path = require("path");
const slsw = require("serverless-webpack");

module.exports = {
  mode: "production",
  entry: slsw.lib.entries,
  resolve: {
    extensions: [".js", ".json", ".ts", ".tsx"],
  },
  output: {
    libraryTarget: "commonjs",
    path: path.join(__dirname, ".webpack"),
    filename: "[name].js",
  },
  externals: ["aws-sdk"],
  target: "node",
  module: {
    rules: [
      {
        test: /\.ts(x?)$/,
        loader: "ts-loader",
      },
    ],
  },
};
