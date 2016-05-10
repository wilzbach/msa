import MSA from "./msa";

const MSAWrapper = function() {
  var msa = function(args) {
    return MSA.apply(this, args);
  };
  msa.prototype = MSA.prototype;
  return new msa(arguments);
};
MSAWrapper.msa = MSA;

export default MSAWrapper;
export {MSA as msa};

// models
export * as model from "./model";

// extra plugins, extensions
export * as menu from "./menu";
export {default as utils} from "./utils";

// probably needed more often
export {default as selection} from  "./g/selection/Selection";
export {default as selcol} from "./g/selection/SelectionCol";
export {default as view} from "backbone-viewj";
export {default as boneView} from "backbone-childs";

// convenience
export {default as _} from 'underscore';
export {default as $} from 'jbone';

// parser (are currently bundled - so we can also expose them)
const io = {};
io.xhr = require('xhr');
io.fasta = require('biojs-io-fasta');
io.clustal = require('biojs-io-clustal');
io.gff = require('biojs-io-gff');

export {io};

export const version = MSA_VERSION;
