module.exports = proxy =

    corsURL: (url, @g) =>
      # do not filter on localhost
      return url if document.URL.indexOf('localhost') >= 0 and url[0] is "/"

      # remove www + http
      url = url.replace "www\.", ""
      url = url.replace "http://", ""

      # prepend proxy
      url = @g.config.get('importProxy') + url
      url
