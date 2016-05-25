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
    currentSize: 3,
    step: 1,
    sizeRange: [1, 5],
    columnWidthRange: [5, 50],
    originalSize: 3,
  },

  initialize: function(args) {
    var params = _.extend({}, this.defaults, args);
    this.sizeRange = params.sizeRange;
    this.set('originalSize', params.currentSize);
    this.columnWidthRange = params.columnWidthRange;
    this.scale = LinearScale().domain(this.sizeRange).range(this.columnWidthRange);
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

    var size = size < this.sizeRange[0] ? this.sizeRange[0]
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

