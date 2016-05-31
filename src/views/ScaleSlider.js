const BoneView = require("backbone-viewj");
const _ = require("underscore");
const $ = require("jbone");
//const Slider = require("bootstrap-slider");

const View = BoneView.extend({


  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:columnWidth", this.render);
    this.toggleClass = 'msa-hide';
    this.isVisible = true;
    return this;
  },

  attributes: {
    class: "msa-scale"
  },

  events: {
    'change input': 'updateSlider',
    'click button.msa-btn-close': 'hide',
    'click button.msa-btn-open': 'show',
    'click button[data-action]': 'clickButton',
  },

  template: _.template('\
<div class="msa-scale-minimised"><button class="btn msa-btn msa-btn-open"><i class="fa fa-angle-double-up" aria-label="Settings"></i></button>\
</div>\
<div class="msa-scale-maximised">\
  <button class="btn msa-btn msa-btn-close" style="float:right"><i class="fa fa-close"></i> close</button>\
  <div>\
  <input type="range" \
    data-provide="slider" \
    min="<%= min %>" \
    max="<%= max %>" \
    step="<%= step %>" \
    value="<%= value %>" \
  >\
  </div>\
  <div class="btngroup msa-btngroup">\
    <button class="btn msa-btn" data-action="smaller"><i class="fa fa-minus" aria-label="zoom out"></i> </button>\
    <button class="btn msa-btn" data-action="bigger"><i class="fa fa-plus" aria-label="zoom in"></i> </button>\
    <button class="btn msa-btn" data-action="reset"><i class="fa fa-refresh" aria-label="reset"></i> </button>\
  </div>\
</div>\
'),

  render: function() {
    const sizeRange = this.model.getSizeRange();
    const stash = {
      value: this.model.getSize(),
      min: sizeRange[0],
      max: sizeRange[1],
      step: this.model.step || 1,
    };
    this.$el.html( this.template(stash) );
    if ( this.isVisible ) {
      this.show();
    }
    else {
      this.hide();
    }
    return this;
  },

  updateSlider: function(e) {
    const target = e.target;
    const size = parseInt( $(target).val() );
    //console.log( "updateSize", size );
    this.model.setSize(size);
  },

  clickButton: function(e) {
    console.log( "clickButton", this, e );
    const target = e.target;
    const action = $(target).data('action');
    const method = this.model[action];
    // bigger, smaller, reset
    if( typeof this.model[action] === 'function' ) {
      this.model[action]();
    }
    return this;
  },

  hide: function() {
    this.isVisible = false;
    this.$el.find(".msa-scale-minimised").removeClass(this.toggleClass);
    this.$el.find(".msa-scale-maximised").addClass(this.toggleClass);
  },

  show: function() {
    this.isVisible = false;
    this.$el.find(".msa-scale-minimised").addClass(this.toggleClass);
    this.$el.find(".msa-scale-maximised").removeClass(this.toggleClass);
  },

});
export default View;
