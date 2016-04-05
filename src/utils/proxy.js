var ProxyHelper;
var _ = require("underscore");

module.exports = ProxyHelper = function(opts) {
  this.g = opts.g;
  return this;
};

var proxyFun =

  {corsURL: function(url) {
    // do not filter on localhost
    if (document.URL.indexOf('localhost') >= 0 && url[0] === "/") { return url; }
    if (url.charAt(0) === "." || url.charAt(0) === "/") { return url; }

    // DEPRECATED as crossorigin.me requires http
    // remove www + http
    //url = url.replace("www\.", "");

    if(this.g.config.get('importProxyStripHttp')){
        url = url.replace("http://", "");
        url = url.replace("https://", "");
    }

    // prepend proxy
    url = this.g.config.get('importProxy') + url;
    return url;
  }
  };

_.extend(ProxyHelper.prototype, proxyFun);
