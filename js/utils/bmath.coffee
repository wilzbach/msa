define [], ->
  # math utilities
  class BMath
    @randomInt: (lower, upper) ->
      # Called with one argument
      [lower, upper] = [0, lower]     unless upper?
      # Lower must be less then upper
      [lower, upper] = [upper, lower] if lower > upper
      # Last statement is a return value
      Math.floor(Math.random() * (upper - lower + 1) + lower)

    # @return [Integer] random id
    @uniqueId: (length = 8) ->
      id = ""
      id += Math.random().toString(36).substr(2) while id.length < length
      id.substr 0, length
