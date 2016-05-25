var StageScale;
var Model = require("backbone-thin").Model;
var LinearScale = require("linear-scale");

// pixel properties for some components
module.exports = StageScale = Model.extend({

  constructor: function(attributes,options) {
    Model.apply(this, arguments);
    this.g = options.g;
    return this;
  },
  
  defaults: {
    // general
    currentSize: 4,
    step: 1,
    originalSize: false,
    scaleBy: 'category',
    columnWidthCategories: [ 3, 5, 8, 12, 20, 30 ],
    sizeRange: [ 1, 5 ],
    columnWidthRange: [ 3, 40 ],
  },

  initialize: function(args) {
    var params = _.extend({}, this.defaults, args);
    this.set('originalSize', params.currentSize);
    this.columnWidthCategories = [ 3, 5, 7, 10, 20, 30 ];
    
    var sizeRange, columnWidthRange, scale;
    if ( params.scaleBy == 'category' ) {
      var categories = params.columnWidthCategories;
      sizeRange = [ 1, categories.length ];
      columnWidthRange = [ _.first( categories ), _.last( categories ) ];
      scale = function (size) { return categories[size - 1] };
    }
    else {
      sizeRange = params.sizeRange;
      columnWidthRange = params.columnWidthRange;
      scale = LinearScale().domain(this.sizeRange).range(this.columnWidthRange);
    }
    this.sizeRange = sizeRange;
    this.columnWidthRange = columnWidthRange;
    this.scale = scale;

    this.setSize( params.currentSize );
    return this;
  },
  
  getColumnWidth: function() {
    var s = this.getSize();
    var w = this.scale(s);
    //console.log( "getColumnWidth", "scale", this.scale, "size", s, "width: ", w);
    return w;
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
    size = parseInt(size);
    size = size < this.sizeRange[0] ? this.sizeRange[0]
         : size > this.sizeRange[1] ? this.sizeRange[1]
         : size;
         
    this.set( 'currentSize', size );
    console.log( "setSize", size, this.getColumnWidth() );
    return this;
  },
  
  getSize: function() {
    return this.get('currentSize');    
  },
  
});

