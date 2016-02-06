var Events = require("biojs-events");

module.exports = class CanvasCharCache {

  constructor(g) {
    this.g = g;
    this.cache = {};
    this.cacheHeight = 0;
    this.cacheWidth = 0;
  }

  // returns a cached canvas
  getFontTile(letter, width, height) {
    // validate cache
    if (width !== this.cacheWidth || height !== this.cacheHeight) {
      this.cacheHeight = height;
      this.cacheWidth = width;
      this.cache = {};
    }

    if (this.cache[letter] === undefined) {
      this.createTile(letter, width, height);
    }

    return this.cache[letter];
  }

  // creates a canvas with a single letter
  // (for the fast font cache)
  createTile(letter, width, height) {

    var canvas = this.cache[letter] = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    this.ctx = canvas.getContext('2d');
    this.ctx.font = this.g.zoomer.get("residueFont") + "px mono";

    this.ctx.textBaseline = 'middle';
    this.ctx.textAlign = "center";

    return this.ctx.fillText(letter,width / 2,height / 2,width);
  }
};
