iced = require("iced-coffee-script")
icedCompiler =
  match: /\.js$/,
  compileSync: (coffeeSourcePath, coffeeSource) ->
    try
      jsAst = iced.compile(coffeeSource, filename: coffeeSourcePath, runtime: "window")
    catch ex
      console.log("Error Compiling '#{coffeeSourcePath}':\r\n" + ex)
    return jsAst

module.exports = icedCompiler