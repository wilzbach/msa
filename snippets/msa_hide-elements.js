var msa = new biojs.vis.msa.msa(yourDiv);
msa.config.visibleElements.ruler = false;
msa.seqmgr.addDummySequences();

// as an example we switch between different states
/*  var state = 0;
    setInterval(function(){
    if(state == 0){
    msa.visibleElements.ruler = false;
    }else{
// display everything again
msa.visibleElements.labels = true;
msa.visibleElements.ruler = true;
}
msa.redrawEntire();
state = (state +1 ) % 2;
}, 3000);
*/


