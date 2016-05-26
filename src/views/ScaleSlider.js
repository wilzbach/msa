const BoneView = require("backbone-viewj");
const _ = require("underscore");
const $ = require("jbone");
//const Slider = require("bootstrap-slider");

const View = BoneView.extend({

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:columnWidth", this.render);
    this.toggleClass = 'msa-hide';
    return this;
  },
  
  attributes: {
    class: "biojs_msa_scale"
  },
  
  events: {
    'change input': 'updateSlider',
    'click button.msa-btn-close': 'hide',
    'click button.msa-btn-open': 'show',
    'click button[data-action]': 'clickButton',
  },
  
  template: _.template('\
<div class="msa-scale-minimised">\
  <button class="btn msa-btn msa-btn-open">Zoom</button>\
</div>\
<div class="msa-scale-maximised">\
  <button class="btn msa-btn msa-btn-close" style="float:right">&times; close</button>\
  <input type="range" \
    data-provide="slider" \
    min="<%= min %>" \
    max="<%= max %>" \
    step="<%= step %>" \
    value="<%= value %>" \
  >\
  <div class="btngroup msa-btngroup">\
    <button class="btn msa-btn" data-action="smaller"><span class="glyphicon-zoom-out"></span>-</button>\
    <button class="btn msa-btn" data-action="bigger"><span class="glyphicon-zoom-in"></span>+</button>\
    <button class="btn msa-btn" data-action="reset"><span class="glyphicon-repeat"></span>reset</button>\
  </div>\
</div>\
'),
  
  render: function() {
    var sizeRange = this.model.getSizeRange();
    var stash = {
      value: this.model.getSize(),
      min: sizeRange[0],
      max: sizeRange[1],
      step: this.model.step || 1,
      colWidth: this.model.getColumnWidth(),
    };
    this.$el.html( this.template(stash) );
    this.hide();    
    return this;
  },

  updateSlider: function(e) {
    var target = e.target;
    var size = parseInt( $(target).val() );
    //console.log( "updateSize", size );
    this.model.setSize(size);
    this.syncModel();
  },

  clickButton: function(e) {
    console.log( "clickButton", this, e );
    var target = e.target;
    var action = $(target).data('action');
    var method = this.model[action];
    // bigger, smaller, reset
    if( typeof this.model[action] === 'function' ) {
      this.model[action]();
      this.syncModel();
    }
    return this;
  },
  
  hide: function() {
    this.$el.find(".msa-scale-minimised").removeClass(this.toggleClass);
    this.$el.find(".msa-scale-maximised").addClass(this.toggleClass);
  },

  show: function() {
    this.$el.find(".msa-scale-minimised").addClass(this.toggleClass);
    this.$el.find(".msa-scale-maximised").removeClass(this.toggleClass);
  },
  
  syncModel: function() {
    var info = this.model.getScaleInfo();
    this.g.zoomer.set('columnWidth', info.columnWidth );
    this.g.zoomer.set('stepSize', info.stepSize );
    this.g.zoomer.set('markerStepSize', info.markerStepSize );
  },
  
});
export default View;
