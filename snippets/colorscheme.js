var msa = window.msa;

// documentation
// https://github.com/wilzbach/biojs-util-colorschemes

// 1) use a pre-defined schema

var opts = {};
opts.seqs = msa.utils.seqgen.genConservedSequences(10,30);
opts.colorscheme = {"scheme": "hydro"};
var a = msa(opts)
yourDiv.appendChild(a.el);
a.render();

// 2) specify your own static schema

opts = {};
opts.seqs = msa.utils.seqgen.genConservedSequences(10,30, "ACGT-");
var b = msa(opts);
yourDiv.appendChild(b.el);
b.g.colorscheme.addStaticScheme("own",{A: "orange", C: "red", G: "green", T: "blue"});
b.g.colorscheme.set("scheme", "own");
b.render();

// 3) create a dynamic schema

opts = {};
opts.seqs = msa.utils.seqgen.genConservedSequences(10,30);
var c = msa(opts);
yourDiv.appendChild(c.el);
c.g.colorscheme.addDynScheme("dyn", function(letter,opts){
  return opts.pos % 2 == 0 ? "#bbb" : "yellow"
});
c.g.colorscheme.set("scheme", "dyn");
c.render();

// 4) create a fancy, dynamic schema

opts = {};
opts.seqs = msa.utils.seqgen.genConservedSequences(10,30, "ACGU");
var d = msa(opts);
yourDiv.appendChild(d.el);

var fun = {}

// the init function is only called once
fun.init = function(){
  // you have here access to the conservation or the sequence object
  this.cons = this.opt.conservation();
}

fun.run = function(letter,opts){
  return this.cons[opts.pos] > 0.8 ? "red" : "#fff"
};

d.g.colorscheme.addDynScheme("dyn", fun);
d.g.colorscheme.set("scheme", "dyn");
d.render();
