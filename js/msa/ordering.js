define([], function(){
var Ordering = function () {

  this.type = "numeric";

  // TODO: do some error checking?
  this.setType = function(type){
    this.type = type;
  };


  // using last known ordering type
  this.getSeqOrder = function(seqs){
    return this.orderSeqsAfterScheme(seqs,this.type);
  };

};

/* 
 * uses a predefined schema to order sequences
 * e.g. alphabatic or numeric
 */
Ordering.prototype.orderSeqsAfterScheme = function (seqs, type){
  var ordering = [];
  if(type === 'numeric'){
    for(var seq in seqs){
      ordering.push(seqs[seq].tSeq.id);
    };
  }else if (type === 'reverse-numeric'){
    for(var seq in seqs){
      ordering.unshift(seqs[seq].tSeq.id);
    };
  }else if (type === 'alphabetic'){
    var tuples = this.sortSeqArrayAlphabetically(seqs);
    for(var i=0;i <tuples.length;i++){
      ordering.push(tuples[i][0]);
    }
  }else if (type === 'reverse-alphabetic'){
    var tuples = this.sortSeqArrayAlphabetically(seqs);
    for(var i=0;i <tuples.length;i++){
      ordering.unshift(tuples[i][0]);
    }
  }
  if(ordering.length == 0) {
    console.log("invalid type selected");
  }else{
    return ordering;
  }
};

Ordering.prototype.sortSeqArrayAlphabetically = function(seqs){
  var tuples= [];
  for (var key in seqs) tuples.push([key, seqs[key].tSeq.name]);

  tuples.sort(function(a,b){
    var nameA = a[1];
    var nameB = b[1];
    if(nameA < nameB) {
      return -1;
    } else if( nameA > nameB){
      return 1;
    }else {
      return 0;
    }
  });
  return tuples;
};

return Ordering;

});
