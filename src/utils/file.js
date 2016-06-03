import {extend} from "lodash";

import {clustal as ClustalReader,
        fasta as FastaReader,
        gff as GffReader, xhr} from "bio.io";

import guessFileType from "./recognize";

const FileHelper = function(msa) {
  this.msa = msa;
  return this;
};

var funs =
  { guessFileFromText: function(text, opt) {
    if (!(typeof text !== "undefined" && text !== null)) {
      console.warn("invalid file format");
      return ["", "error"];
    }
    const recognizedFile = guessFileType(text, opt);
    switch (recognizedFile) {
      case "clustal":
        var reader = ClustalReader;
        var type = "seqs";
        break;

      case "fasta":
        reader = FastaReader;
        type = "seqs";
        break;

      case "newick":
        type = "newick";
        break;

      case "gff":
        reader = GffReader;
        type = "features";
        break;

      default:
        alert("Unknown file format. Please contact us on Github for help.");
        break;
    }
    return [reader,type];
  },

  parseText: function(text, opt) {
    var [reader, type] = this.guessFileFromText(text, opt);
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

  importFile: function(file, opt) {
    opt = opt || {};
    opt.name = file.name;
    var fileName;
    var [objs, type] = this.parseText(file, opt);
    if (type === "error") {
        alert("An error happened");
        return "error";
    }
    if (type === "seqs") {
      this.msa.seqs.reset(objs);
      this.msa.g.config.set("url", "userimport");
      this.msa.g.trigger("url:userImport");
    } else if (type === "features") {
      this.msa.seqs.addFeatures(objs);
    } else if (type === "newick") {
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
        var res = this.importFile(body, {url: url});
        if (res === "error") {
          return;
        }
        this.msa.g.trigger("import:url", url);
        if (cb) {
          return cb();
        }
      } else {
        return console.error(err);
      }
    });
  }
  };

extend(FileHelper.prototype, funs);
export default FileHelper;
