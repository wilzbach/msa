var Sequence = require("biojs-model").seq;
var BMath = require("./bmath");
var Stat = require("stat.seqs");

var seqgen = module.exports =
  {_generateSequence: function(len) {
    var text = "";
    var end = len - 1;
    for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      text += seqgen.getRandomChar();
    }
    return text;
  },

  // generates a dummy sequences
  // @param len [int] number of generated sequences
  // @param seqLen [int] length of the generated sequences
  getDummySequences: function(len, seqLen) {
    var seqs = [];
    if (!(typeof len !== "undefined" && len !== null)) { len = BMath.getRandomInt(3,5); }
    if (!(typeof seqLen !== "undefined" && seqLen !== null)) { seqLen = BMath.getRandomInt(50,200); }

    for (var i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      seqs.push(new Sequence(seqgen._generateSequence(seqLen), "seq" + i,"r" + i));
    }
    return seqs;
  },

  getRandomChar: function(dict) {
    var possible = dict || "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return possible.charAt(Math.floor(Math.random() * possible.length));
  },

  // generates a dummy sequences
  // @param len [int] number of generated sequences
  // @param seqLen [int] length of the generated sequences
  genConservedSequences: function(len, seqLen, dict) {
    var seqs = [];
    if (!(typeof len !== "undefined" && len !== null)) { len = BMath.getRandomInt(3,5); }
    if (!(typeof seqLen !== "undefined" && seqLen !== null)) { seqLen = BMath.getRandomInt(50,200); }

    dict = dict || "ACDEFGHIKLMNPQRSTVWY---";

    for (var i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      seqs[i-1] = "";
    }

    var tolerance = 0.2;

    var conservAim = 1;
    var end = seqLen - 1;
    for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      if (i % 3 === 0) {
        conservAim = (BMath.getRandomInt(50,100)) / 100;
      }
      var observed = [];
      var end1 = len - 1;
      for (var j = 0; 0 < end1 ? j <= end1 : j >= end1; 0 < end1 ? j++ : j--) {
        var counter = 0;
        while (counter < 100) {
          var c = seqgen.getRandomChar(dict);
          var cConserv = Stat(observed);
          cConserv.addSeq(c);
          counter++;
          if (Math.abs(conservAim - cConserv.scale(cConserv.conservation())[0]) < tolerance) {
            break;
          }
        }
        seqs[j] += c;
        observed.push(c);
      }
    }

    var pseqs = [];
    for (var i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      pseqs.push(new Sequence(seqs[i-1], "seq" + i, "r" + i));
    }

    return pseqs;
  }
  };
