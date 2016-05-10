// mini svg helper

const svgns = "http://www.w3.org/2000/svg";

const setAttr = function(obj,opts) {
  for (var name in opts) {
    var value = opts[name];
    obj.setAttributeNS(null, name, value);
  }
  return obj;
};

const Base = function(opts) {
  var svg = document.createElementNS(svgns, 'svg');
  svg.setAttribute("width", opts.width);
  svg.setAttribute("height", opts.height);
  return svg;
};

const Rect = function(opts) {
  var rect = document.createElementNS(svgns, 'rect');
  return setAttr(rect,opts);
};

const Line = function(opts) {
  var line = document.createElementNS(svgns, 'line');
  return setAttr(line,opts);
};

const Polygon = function(opts) {
  var line = document.createElementNS(svgns, 'polygon');
  return setAttr(line,opts);
};

export {Base as base, Line as line,
  Rect as rect, Polygon as polygon};
