const Sequence = require("biojs-model").seq;
import BMath from "./bmath";
const Stat = require("stat.seqs");

const SeqGen = {
  _generateSequence: (len) => {
    let text = "";
    const end = len - 1;
    for (let i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      text += SeqGen.getRandomChar();
    }
    return text;
  },

  // generates a dummy sequences
  // @param len [int] number of generated sequences
  // @param seqLen [int] length of the generated sequences
  getDummySequences: function(len, seqLen) {
    const seqs = [];
    if (!(typeof len !== "undefined" && len !== null)) { len = BMath.getRandomInt(3,5); }
    if (!(typeof seqLen !== "undefined" && seqLen !== null)) { seqLen = BMath.getRandomInt(50,200); }

    for (var i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      seqs.push(new Sequence(SeqGen._generateSequence(seqLen), "seq" + i,"r" + i));
    }
    return seqs;
  },

  getRandomChar: (dict) => {
    const possible = dict || "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return possible.charAt(Math.floor(Math.random() * possible.length));
  },

  // generates a dummy sequences
  // @param len [int] number of generated sequences
  // @param seqLen [int] length of the generated sequences
  genConservedSequences: (len, seqLen, dict) => {
    const seqs = [];
    if (!(typeof len !== "undefined" && len !== null)) { len = BMath.getRandomInt(3,5); }
    if (!(typeof seqLen !== "undefined" && seqLen !== null)) { seqLen = BMath.getRandomInt(50,200); }

    dict = dict || "ACDEFGHIKLMNPQRSTVWY---";

    for (let i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      seqs[i-1] = "";
    }

    const tolerance = 0.2;

    let conservAim = 1;
    const end = seqLen - 1;
    for (let i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      if (i % 3 === 0) {
        conservAim = (BMath.getRandomInt(50,100)) / 100;
      }
      const observed = [];
      const end1 = len - 1;
      for (let j = 0; 0 < end1 ? j <= end1 : j >= end1; 0 < end1 ? j++ : j--) {
        let counter = 0;
        let c;
        while (counter < 100) {
          c = SeqGen.getRandomChar(dict);
          const cConserv = Stat(observed);
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

    const pseqs = [];
    for (var i = 1; 1 < len ? i <= len : i >= len; 1 < len ? i++ : i--) {
      pseqs.push(new Sequence(seqs[i-1], "seq" + i, "r" + i));
    }

    return pseqs;
  }
};
export default SeqGen;
