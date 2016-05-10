const _ = require("underscore");
const Events = require("biojs-events");

var cache =

  {setMaxScrollHeight() {
    return this.maxScrollHeight = this.g.zoomer.getMaxAlignmentHeight() - this.g.zoomer.get('alignmentHeight');
  },

  setMaxScrollWidth() {
    return this.maxScrollWidth = this.g.zoomer.getMaxAlignmentWidth() - this.g.zoomer.getAlignmentWidth();
  }
  };

const CacheConstructor = function(g,model) {
  this.g = g;
  this.model = model;
  this.maxScrollWidth = 0;
  this.maxScrollHeight = 0;
  this.setMaxScrollHeight();
  this.setMaxScrollWidth();

  this.listenTo(this.g.zoomer, "change:rowHeight", this.setMaxScrollHeight);
  this.listenTo(this.g.zoomer, "change:columnWidth", this.setMaxScrollWidth);
  this.listenTo(this.g.zoomer, "change:alignmentWidth", this.setMaxScrollWidth);
  this.listenTo(this.g.zoomer, "change:alignmentHeight", this.setMaxScrollHeight);
  this.listenTo( this.model, "add change reset", (function() {
    this.setMaxScrollHeight();
    return this.setMaxScrollWidth();
  }), this
  );
  return this;
};

_.extend(CacheConstructor.prototype, cache);
Events.mixin(CacheConstructor.prototype);
export default CacheConstructor;
