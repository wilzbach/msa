/**
 * Given a file type - what is typical for it?
 */

const isClustal = function(text, suffix)
{
    if (text.substring(0,7) === "CLUSTAL" || suffix == "clustal" || suffix == "aln") {
        return "clustal";
    }
    return false;
}

const isFasta = function(text, suffix)
{
    if (text.substring(0,1) === ">" || suffix == "fasta" || suffix == "fa") {
        return "fasta";
    }
    return false;
}

const isNewick = function(text, suffix)
{
    if (text.substring(0,1) === "(" || suffix == "nwk") {
        return "newick";
    }
    return false;
}

const isGFF = function(text, suffix)
{
    if (text.length <= 10) {
        return false;
    }
    const lines = text.split('\n');
    if (lines[0].indexOf("gff") >= 0 || suffix.indexOf("gff") >= 0) {
        return "gff";
    }
    if (lines[0].indexOf("#") < 0 && lines[0].split("\t").length === 2) {
        // no comments and two columns. let's hope this is from jalview
        return "gff";
    }
    return false;
}

const recognizers = [isClustal, isFasta, isNewick, isGFF];

/**
Return the lowercase format for a given file
*/
export default function(text, opt) {
    const fileName = opt.name || opt.url || "";
    const fileNameSplit = fileName.split(".");
    let suffix = fileNameSplit[fileNameSplit.length - 1] || "";
    for (var i = 0; i < recognizers.length; i++) {
        var v = recognizers[i](text, suffix);
        if (!!v)
            return v;
    }
    return "unknown";
}
