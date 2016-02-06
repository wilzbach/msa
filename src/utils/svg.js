// mini svg helper

var svgns = "http://www.w3.org/2000/svg";

var setAttr = function(obj,opts) {
  for (var name in opts) {
    var value = opts[name];
    obj.setAttributeNS(null, name, value);
  }
  return obj;
};

var Base = function(opts) {
  var svg = document.createElementNS(svgns, 'svg');
  svg.setAttribute("width", opts.width);
  svg.setAttribute("height", opts.height);
  return svg;
};

var Rect = function(opts) {
  var rect = document.createElementNS(svgns, 'rect');
  return setAttr(rect,opts);
};

var Line = function(opts) {
  var line = document.createElementNS(svgns, 'line');
  return setAttr(line,opts);
};

var Polygon = function(opts) {
  var line = document.createElementNS(svgns, 'polygon');
  return setAttr(line,opts);
};

module.exports.rect = Rect;
module.exports.line = Line;
module.exports.polygon = Polygon;
module.exports.base = Base;
