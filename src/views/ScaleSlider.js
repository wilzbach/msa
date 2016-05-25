const BoneView = require("backbone-viewj");
const _ = require("underscore");
const $ = require("jbone");
//const Slider = require("bootstrap-slider");

const View = BoneView.extend({

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:columnWidth", this.render);
    return this;
  },
  
  attributes: {
    class: "biojs_msa_scale"
  },
  
  events: {
    'change input': 'updateSlider',
    'click button': 'clickButton',
  },
  
  template: _.template('\
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
'),
  
  render: function() {
    var sizeRange = this.model.sizeRange;
    var stash = {
      value: this.model.getSize(),
      min: sizeRange[0],
      max: sizeRange[1],
      step: this.model.step || 1,
      colWidth: this.model.getColumnWidth(),
    };
    this.$el.html( this.template(stash) );
    return this;
  },

  updateSlider: function(e) {
    console.log("ScaleSlider.updateSlider", e);
    var target = e.target;
    var size = parseInt( $(target).val() );
    //console.log( "updateSize", size );
    this.model.setSize(size);
    this.syncModel();
  },

  clickButton: function(e) {
    console.log("ScaleSlider.clickButton", e);
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
  
  syncModel: function() {
    console.log("ScaleSlider.syncModel");
    var colWidth = this.model.getColumnWidth();
    this.g.zoomer.set('columnWidth', colWidth );
  }
  
});
export default View;
