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
      { columnWidth: 45, markerStepSize: 1, stepSize: 1 },
    ],
  },

  initialize: function(args) {
    const categories = this.get('scaleCategories');
    const initialColumnWidth = this.g.zoomer.get('columnWidth') || this._getScaleInfo().columnWidth;

    /* if the global columnWidth setting doesn't match any of our categories
     * then create a category that does match and add it to a sensible place
     * in the list
     */
    var category = _.find( categories, { columnWidth: initialColumnWidth });
    if (!category) {
      const catindex = this._insertScaleCategory( initialColumnWidth );
      category = categories[ catindex ];
      // custom columnWidth should overwrite the default currentSize
      this.set('currentSize', catindex + 1);
    }

    const currentSize = this.get('currentSize');
    this.set('originalSize', currentSize);
    this.setSize(currentSize);

    return this;
  },

  // insert new category based on columnWidth
  // return the index of newly inserted category
  _insertScaleCategory: function(columnWidth) {
    let categories = this.get('scaleCategories');
    const lastcatindex = _.findLastIndex( categories, c => c.columnWidth < columnWidth);
    const lastcat = categories[lastcatindex];
    const insertindex = lastcatindex + 1;
    const category = { columnWidth: columnWidth, markerStepSize: lastcat.markerStepSize, stepSize: lastcat.markerStepSize };
    categories.splice( insertindex, 0, category );
    this.set('scaleCategories', categories);
    return insertindex;
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
