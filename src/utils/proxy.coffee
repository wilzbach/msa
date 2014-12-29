_ = require "underscore"

module.exports = ProxyHelper = (opts) ->
  @g = opts.g
  @

proxyFun =

  corsURL: (url) ->
    # do not filter on localhost
    return url if document.URL.indexOf('localhost') >= 0 and url[0] is "/"
    return url if url.charAt(0) is "." or url.charAt(0) is "/"

    # remove www + http
    url = url.replace "www\.", ""
    url = url.replace "http://", ""

    # prepend proxy
    url = @g.config.get('importProxy') + url
    url

_.extend ProxyHelper::, proxyFun
