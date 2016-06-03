import {extend} from "lodash";

import {clustal as ClustalReader,
        fasta as FastaReader,
        gff as GffReader, xhr} from "bio.io/src/index_plain";

const FileHelper = function(msa) {
  this.msa = msa;
  return this;
};

var funs =
  {guessFileType: function(name) {
    name = name.split(".");
    var fileName = name[name.length(-1)];
    switch (fileName) {
      case "aln": case "clustal": return ClustalReader; break;
      case "fasta": return FastaReader; break;
      default:
        return FastaReader;
    }
  },

  guessFileFromText: function(text) {
    if (!(typeof text !== "undefined" && text !== null)) {
      console.warn("invalid file format");
      return ["", "error"];
    }
    if (text.substring(0,7) === "CLUSTAL") {
      var reader = ClustalReader;
      var type = "seqs";
    } else if (text.substring(0,1) === ">") {
      reader = FastaReader;
      type = "seqs";
    } else if (text.substring(0,1) === "(") {
      type = "newick";
    } else {
      reader = GffReader;
      type = "features";
    }
      //console.warn "Unknown format. Contact greenify"
    return [reader,type];
  },

  parseText: function(text) {
    var [reader, type] = this.guessFileFromText(text);
    if (type === "seqs") {
      var seqs = reader.parse(text);
      return [seqs,type];
    } else if (type === "features") {
      var features = reader.parseSeqs(text);
      return [features,type];
    } else {
      return [text,type];
    }
  },

  importFiles: function(files) {
    return (() => {
      var result = [];
      var end = files.length - 1;
      for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
        var file = files[i];
        var reader = new FileReader();
        reader.onload = (evt) => {
          return this.importFile(evt.target.result);
        };
        result.push(reader.readAsText(file));
      }
      return result;
    })();
  },

  importFile: function(file) {
    var fileName;
    var [objs, type] = this.parseText(file);
    if (type === "error") {
        alert("An error happened");
        return "error";
    }
    if (type === "seqs") {
      this.msa.seqs.reset(objs);
      this.msa.g.config.set("url", "userimport");
      this.msa.g.trigger("url:userImport");
    } else if (type === "features") {
      console.error("Loading Feature files is experimental. Please open a issue on github if you run into troubles");
      this.msa.seqs.addFeatures(objs);
    } else if (type === "newick") {
      console.error("Loading Newick files is experimental. Please open a issue on github if you run into troubles");
      this.msa.u.tree.loadTree(() => {
        return this.msa.u.tree.showTree(file);
      });
    } else {
      alert("Unknown file!");
    }

    return fileName = file.name;
  },

  importURL: function(url, cb) {
    url = this.msa.u.proxy.corsURL(url);
    this.msa.g.config.set("url", url);
    return xhr({
        url: url,
        timeout: 0
    }, (err,status,body) => {
      if (!err) {
        var res = this.importFile(body);
        if (res === "error") {
          return;
        }
        this.msa.g.trigger("import:url", url);
        if (cb) {
          return cb();
        }
      } else {
        return console.log(err);
      }
    });
  }
  };

extend(FileHelper.prototype, funs);
export default FileHelper;
