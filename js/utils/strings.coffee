define [], ->
  {
    contains: (a, str) ->
      return -1 isnt a.indexOf str

    trim: (str) ->
      str.replace(/^\s+|\s+$/g, '')
  }
