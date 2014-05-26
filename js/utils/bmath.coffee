define [], () ->
  class BMath
    @randomInt : (lower, upper) ->
      [lower, upper] = [0, lower]     unless upper?           # Called with one argument
      [lower, upper] = [upper, lower] if lower > upper        # Lower must be less then upper
      Math.floor(Math.random() * (upper - lower + 1) + lower) # Last statement is a return value

    @uniqueId: (length=8) ->
      id = ""
      id += Math.random().toString(36).substr(2) while id.length < length
      id.substr 0, length
