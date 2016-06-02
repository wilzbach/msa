const BoneView = require("backbone-viewj");
import {template} from "lodash";
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
    class: "biojs_msa_scale"
  },

  events: {
    'change input': 'updateSlider',
    'click button.msa-btn-close': 'hide',
    'click button.msa-btn-open': 'show',
    'click button[data-action]': 'clickButton',
  },

  template: template('\
<div class="msa-scale-minimised">\
  <button class="btn msa-btn msa-btn-open">Zoom</button>\
</div>\
<div class="msa-scale-maximised">\
  <button class="btn msa-btn msa-btn-close" style="float:right">&times; close</button>\
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
    <button class="btn msa-btn" data-action="smaller"><span class="glyphicon-zoom-out"></span>-</button>\
    <button class="btn msa-btn" data-action="bigger"><span class="glyphicon-zoom-in"></span>+</button>\
    <button class="btn msa-btn" data-action="reset"><span class="glyphicon-repeat"></span>reset</button>\
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
