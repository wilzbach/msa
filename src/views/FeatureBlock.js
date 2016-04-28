
  // draws features
  ({appendFeature: function(data) {
    var f = data.f;
    // TODO: this is a very naive way
    var boxWidth = this.g.zoomer.get("columnWidth");
    var boxHeight = this.g.zoomer.get("rowHeight");
    var width = (f.get("xEnd") - f.get("xStart")) * boxWidth;

    var beforeWidth = this.ctx.lineWidth;
    this.ctx.lineWidth = 3;
    var beforeStyle = this.ctx.strokeStyle;
    this.ctx.strokeStyle = f.get("fillColor");

    this.ctx.strokeRect(data.xZero, data.yZero, width,boxHeight);
    this.ctx.strokeStyle = beforeStyle;
    return this.ctx.lineWidth = beforeWidth;
  },

  drawFeature: function(data) {
    var seq = data.model.get("seq");
    var rectWidth = this.g.zoomer.get("columnWidth");
    var rectHeight = this.g.zoomer.get("rowHeight");

    var start = Math.max(0, Math.abs(Math.ceil( - this.g.zoomer.get('_alignmentScrollLeft') / rectWidth)));
    var x = - Math.abs( - this.g.zoomer.get('_alignmentScrollLeft') % rectWidth);
    var xZero = x - start * rectWidth;

    var features = data.model.get("features");

    var yZero = data.y;

    return (() => {
      var result = [];
      var end = seq.length - 1;
      for (var j = start; start < end ? j <= end : j >= end; start < end ? j++ : j--) {
        var starts = features.startOn(j);

        if (data.hidden.indexOf(j) >= 0) {
          continue;
        }

        if (starts.length > 0) {
          for (var i = 0, f; i < starts.length; i++) {
            f = starts[i];
            this.appendFeature({f: f,xZero: x, yZero: yZero});
          }
        }

        x = x + rectWidth;
        // out of viewport - stop
        result.push((() => {
          if (x > this.el.width) {
            return;
          }
        })());
      }
      return result;
    })();
  }
  });
