module.exports =
  // math utilities
  class BMath {
    static randomInt(lower, upper) {
      // Called with one argument
      if (!(typeof upper !== "undefined" && upper !== null)) { [lower, upper] = [0, lower]; }
      // Lower must be less then upper
      if (lower > upper) { [lower, upper] = [upper, lower]; }
      // Last statement is a return value
      return Math.floor(Math.random() * (upper - lower + 1) + lower);
    }

    // @return [Integer] random id
    static uniqueId(length = 8) {
      var id = "";
      while (id.length < length) {
        id += Math.random().toString(36).substr(2);
      }
      return id.substr(0, length);
    }

    // Returns a random integer between min (inclusive) and max (inclusive)
    static getRandomInt(min, max) {
      return Math.floor(Math.random() * (max - min + 1)) + min;
    }
  };
