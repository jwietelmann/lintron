// Generated by CoffeeScript 1.7.1
(function() {
  var NoDebugger;

  module.exports = NoDebugger = (function() {
    function NoDebugger() {}

    NoDebugger.prototype.rule = {
      name: 'no_debugger',
      level: 'warn',
      message: 'Debugger statements will cause warnings',
      description: "This rule detects the `debugger` statement.\nThis rule is `warn` by default."
    };

    NoDebugger.prototype.tokens = ["DEBUGGER"];

    NoDebugger.prototype.lintToken = function(token, tokenApi) {
      return {
        context: "found '" + token[0] + "'"
      };
    };

    return NoDebugger;

  })();

}).call(this);