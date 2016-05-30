var StageScale;
var Model = require("backbone-thin").Model;
var LinearScale = require("linear-scale");

// pixel properties for some components
module.exports = StageScale = Model.extend({

  constructor: function(attributes,options) {
    this.g = options.g;
    Model.apply(this, arguments);
    return this;
  },

  defaults: {
    // general
    currentSize: 5,
    step: 1,
    originalSize: false,
    scaleCategories: [
      { columnWidth: 1, markerStepSize: 20, stepSize: 0 },
      { columnWidth: 3, markerStepSize: 20, stepSize: 0 },
      { columnWidth: 5, markerStepSize: 10, stepSize: 0 },
      { columnWidth: 9, markerStepSize: 5, stepSize: 1 },
      { columnWidth: 15, markerStepSize: 2, stepSize: 1 },
      { columnWidth: 20, markerStepSize: 1, stepSize: 1 },
      { columnWidth: 30, markerStepSize: 1, stepSize: 1 },
    ],
  },

  initialize: function(args) {
    const currentSize = this.get('currentSize');
    this.set('originalSize', currentSize);
    // TODO: don't overwrite the default settings
    //this.setSize( currentSize );

    return this;
  },

  getSizeRange() {
    return [ 1, this.get('scaleCategories').length ];
  },

  bigger: function(){
    return this.setSize( this.get('currentSize') + this.get('step') );
  },

  smaller: function(){
    return this.setSize( this.get('currentSize') - this.get('step') );
  },

  reset: function() {
    return this.setSize( this.get('originalSize') );
  },

  setSize: function(size) {
    const range = this.getSizeRange();
    size = parseInt(size);
    size = size < range[0] ? range[0]
         : size > range[1] ? range[1]
         : size;

    this.set('currentSize', size);
    const info = this._getScaleInfo();
    this.g.zoomer.set({
        columnWidth: info.columnWidth,
        //rowHeight: columnWidth,
        stepSize: info.stepSize,
        markerStepSize: info.markerStepSize,
        // update font too (hackish)
        //residueFont: nFontSize,
        //labelFontSize:  nFontSize
    });
    return this;
  },

  getSize: function() {
    return this.get('currentSize');
  },

  _getScaleInfo: function() {
    const size = this.getSize();
    const categories = this.get('scaleCategories');
    if ( size > 0 && size <= categories.length ) {
      return categories[size-1];
    }
    else {
      console.error( "out of bounds" );
    }
  }
});

