require("./browser");

if (typeof biojs.io === 'undefined') {
  biojs.io = {};
}

biojs.io.fasta = require("biojs-io-fasta");
biojs.io.clustal = require("biojs-io-clustal");
