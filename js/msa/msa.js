define(["./colorator", "./sequence", "./ordering", "./menu", "./utils", "./labelcolorator", "./row"], function(Colorator, Sequence, Ordering, Menu, Utils, LabelColorator, Row) {
  return function msa(divName){

    var _self = this;

    this.columnWidth = 20;
    this.columnHeight = 20;
    this.columnSpacing = 5;
    // how much space for the labels?
    this.seqOffset = 140;

    this.colorscheme = new Colorator(); 
    this.labelColorScheme = new LabelColorator();
    this.ordering = new Ordering();
    this.visibleElements = {
      labels: true, sequences: true, menubar: true, ruler: true};

    // an Array of BioJS.MSA.Row
    this.seqs = [];

    this._currentRow= -1;
    this._currentColumn= -1;
    this._currentPos = {'x': -1, 'y': -1 };


    // create menubar  + canvas
    this.console = document.getElementById("console");
    this.container = document.getElementById(divName);

    // BEGIN : CONSTRUCTOR

    this.stageID =  String.fromCharCode(65 + Math.floor(Math.random() * 26));
    this.globalID = 'biojs_msa_' + this.stageID;

    this.menu = new Menu(this);
    this.stage= document.createElement("div");
    this.stage.setAttribute("id",this.globalID+"_canvas"); 
    this.stage.setAttribute("class", "biojs_msa_stage");
    this.container.appendChild(this.menu.menu);
    this.container.appendChild(this.stage);

    //this._seqMarkerLayer = "<div id='"+ this.globalId + "_marker"'></div>";
    this._seqMarkerLayer = document.createElement("div");
    this._seqMarkerLayer.className = "biojs_msa_marker";
    this._seqMarkerLayer.style.paddingLeft = this.seqOffset + "px";
    this.stage.appendChild(this._seqMarkerLayer);

    this.stage.style.cursor = "default";

    // END : CONSTRUCTOR

    this.addDummySequences = function(){
      // define seqs
      seqs = [new Sequence("MSPFTACAPDRLNAGECTF", "awesome name", 1)
        ,new Sequence("QQTSPLQQQDILDMTVYCD", "awesome name2", 2)
        ,new Sequence("FTQHGMSGHEISPPSEPGH", "awesome name3", 3)];

      this.addSequences(seqs);
    }

    this._addSequence = function(tSeq){

      var layer = document.createElement("div");

      if(this.visibleElements.labels === true){
        layer.appendChild(this._createLabel(tSeq));
      }

      if(this.visibleElements.sequences === true){
        layer.appendChild(this._createSeqRow(tSeq)); 
      }

      layer.className = "biojs_msa_layer";

      // append to DOM
      this.stage.appendChild(layer);

      // save and add the layer
      this.seqs[tSeq.id] = new Row(tSeq,layer);

      //order the stuff ?
    };

    this.addSequence = function(tSeq){
      this.addSequence(tSeq);
      this.orderSeqsAfterScheme();
    };

    this.addSequences= function (tSeqs){

      for(var i=0;i<tSeqs.length;i++){
        this._addSequence(tSeqs[i]);
      }

      this.orderSeqsAfterScheme();
    };

    /* 
     * creates all amino acids
     */
    this._createSeqRow = function(tSeq){

      var residueGroup = document.createDocumentFragment();

      for(var n = 0; n < tSeq.seq.length; n++) {
        var residueSpan = document.createElement("span");
        residueSpan.style.width = this.columnWidth + "px";
        residueSpan.textContent = tSeq.seq[n];
        residueSpan.rowPos = n;

        residueSpan.addEventListener('click',function(evt){

          var id = this.parentNode.seqid;
          _self.selectResidue(id,this.rowPos);
          // send event
          _self.onPositionClicked(id,this.rowPos);
        }, false);


        residueSpan.addEventListener('mouseover',function(evt){

          var id = this.parentNode.seqid;
          _self.selectResidue(id,this.rowPos);
          // send event
          _self.onPositionClicked(id,this.rowPos);
        }, false);


        // color it nicely
        this.colorscheme.colorResidue(residueSpan, tSeq, n);

        residueGroup.appendChild(residueSpan);
      }

      var residueSpan = document.createElement("span");
      residueSpan.seqid = tSeq.id;
      residueSpan.className = "biojs_msa_sequence_block";
      residueSpan.appendChild(residueGroup);
      return residueSpan;
    };

    this._drawSeqMarker = function(nMax){

      // using fragments is the fastest way
      // try to minimize DOM updates as much as possible
      // http://jsperf.com/innerhtml-vs-createelement-test/6
      var residueGroup = document.createDocumentFragment();

      for(var n = 0; n < nMax; n++) {
        var residueSpan = document.createElement("span");

        residueSpan.textContent = n;
        residueSpan.style.width = this.columnWidth + "px";
        residueSpan.style.display = "inline-block";
        residueSpan.rowPos = n;

        residueSpan.addEventListener('click',function(evt){

          _self._cleanupSelections();

          // color the selected residues
          _self.selectColumn(this.rowPos);

          // send events
          _self.onColumnSelect(this.rowPos);

        }, false);

        residueSpan.addEventListener('mouseover',function(evt){

          _self._cleanupSelections();

          // color the selected residues
          _self.selectColumn(this.rowPos);

          // send events
          _self.onColumnSelect(this.rowPos);

        }, false);

        // color it nicely
        this.colorscheme.colorColumn(residueSpan, n);
        residueGroup.appendChild(residueSpan);
      }
      return residueGroup;
    };


    /*
     * creates the label of a single seq
     */
    this._createLabel = function(tSeq){

      var labelGroup = document.createElement("span");

      labelGroup.textContent = tSeq.name;
      labelGroup.seqid= tSeq.id;
      labelGroup.className = "biojs_msa_labels";
      labelGroup.style.width = this.seqOffset + "px";

      labelGroup.addEventListener('click',function(evt){
        id = this.seqid;
        _self.onRowSelect(id);
        _self.selectSeq(id);
      }, false);

      labelGroup.addEventListener('mouseover',function(evt){
        id = this.seqid;
        _self.onRowSelect(id);
        _self.selectSeq(id);
      }, false);

      this.labelColorScheme.colorLabel(labelGroup,tSeq);

      return labelGroup;
    }

    this.orderSeqsAfterScheme = function(type){
      if(typeof type !== "undefined"){
        this.ordering.setType(type);
      }
      this.orderSeqs(this.ordering.getSeqOrder(this.seqs));
    }

    /* 
     * receives an ordered list with seq ids
     */
    this.orderSeqs = function (orderList){
      if(orderList.length != Object.size(this.seqs) ){
        this.log("Length of the input array "+ orderList.length +" does not match with the real world " + Object.size(this.seqs));
        return;
      }

      var spacePerCell = this.columnHeight + this.columnSpacing;
      var val = 0;

      nMax = 0;
      this.seqs.forEach(function(entry){
        nMax = Math.max(nMax, entry.tSeq.seq.length);
      });


      Utils.removeAllChilds(this._seqMarkerLayer);

      // remove offset
      if(this.visibleElements.labels === false){
        this._seqMarkerLayer.style.paddingLeft= "0px";
      }

      if( this.visibleElements.ruler === true){
        val = spacePerCell;
        this._seqMarkerLayer.appendChild(this._drawSeqMarker(nMax));
      }

      var frag = document.createDocumentFragment();
      frag.appendChild(this._seqMarkerLayer);
      for(var i=0;i<orderList.length;i++){
        var id = orderList[i];
        this.seqs[id].layer.style.paddingTop= this.columnSpacing +"px";
        //val += spacePerCell;
        frag.appendChild(this.seqs[id].layer);
      }

      Utils.removeAllChilds(this.stage);
      this.stage.appendChild(frag);

      // update width
      this.stage.width = ( this.seqOffset + nMax * this.columnWidth);

    };

    /**
     * Selects a row (does not send any event)
     */
    this.selectSeq = function(id){

      this._cleanupSelections();

      var currentLayer = _self.seqs[id].layer;
      var tSeq = _self.seqs[id].tSeq;

      // color selected row
      var childs = currentLayer.childNodes[1].childNodes;
      for(var i=0; i< childs.length; i++){
        _self.colorscheme.colorSelectedResidue(childs[i],tSeq,i);
      }

      // label
      var currentLayerLabel = currentLayer.children[0];
      _self.labelColorScheme.colorSelectedLabel(currentLayerLabel, tSeq);

      _self._currentRow =id;
    };

    this.removeSeq  = function(id){
      this.seqs[id].layer.destroy();
      delete this.seqs[id];

      //reorder ??
    };


    this.selectResidue = function (id,rowPos){
      this._cleanupSelections();

      var tSeq = _self.seqs[id].tSeq;

      // color the selected residue
      var singleResidue = _self.seqs[id].layer.children[1].children[rowPos];
      _self.colorscheme.colorSelectedResidueSingle(singleResidue,tSeq,rowPos);

      // send events
      _self.onPositionClicked(id,rowPos);
      _self._currentPos.y = id;
      _self._currentPos.x = rowPos;
    };

    this.selectColumn = function(selColumn){
      this._cleanupSelections();

      if( selColumn >= 0 ){
        var columnGroup = _self._seqMarkerLayer.childNodes[selColumn];
        _self.colorscheme.colorSelectedColumn(columnGroup, selColumn);
        for( var seq in _self.seqs){
          var singlePos = _self.seqs[seq].layer.children[1].childNodes[selColumn];
          _self.colorscheme.colorSelectedResidueColumn(singlePos,_self.seqs[seq].tSeq,singlePos.rowPos);
        }
      }
      _self._currentColumn = selColumn;
    }


    /*
     * removes all existing selections
     */
    this._cleanupSelections = function(){

      this._removeHorizontalSelection();
      this._removeVerticalSelection();
      this._removePositionSelection();
    }

    this._removePositionSelection = function(){
      var currentPos = _self._currentPos;
      if( currentPos.x >= 0 && currentPos.y >= 0){
        var singlePos =_self.seqs[currentPos.y].layer.childNodes[1].childNodes[currentPos.x];
        var tSeq = _self.seqs[currentPos.y].tSeq;
        _self.colorscheme.colorResidue(singlePos,tSeq, currentPos.x);
      }
    }

    this._removeVerticalSelection = function(){
      var currentColumn = _self._currentColumn;
      if( currentColumn >= 0 ){
        var columnGroup = _self._seqMarkerLayer.childNodes[currentColumn];
        _self.colorscheme.colorColumn(columnGroup, currentColumn);
        for( var seq in _self.seqs){
          var singlePos = _self.seqs[seq].layer.childNodes[1].childNodes[currentColumn];
          _self.colorscheme.colorResidue(singlePos,_self.seqs[seq].tSeq,singlePos.rowPos);
        }
      }
    }

    this._removeHorizontalSelection = function(){
      var currentRow = _self._currentRow;
      if(currentRow >= 0){
        var tSeq = _self.seqs[currentRow].tSeq;
        var currentLayer = _self.seqs[currentRow].layer;

        // all residues
        var childs = currentLayer.childNodes[1].childNodes;
        for(var i=0; i< childs.length; i++){
          _self.colorscheme.colorResidue(childs[i],tSeq,i);
        }

        // label
        var currentLayerLabel = currentLayer.childNodes[0];
        _self.labelColorScheme.colorLabel(currentLayerLabel,tSeq);
      }
    }

    /*
     * redraws the entire MSA
     */
    this.redraw = function(){

      this._cleanupSelections();

      // all columns
      for( var curRow in _self.seqs){

        var tSeq = _self.seqs[curRow].tSeq;
        var currentLayer = _self.seqs[curRow].layer;

        // all residues
        var childs = currentLayer.childNodes[1].childNodes;
        for(var i=0; i< childs.length; i++){
          _self.colorscheme.colorResidue(childs[i],tSeq, childs[i].rowPos);
        }

        //labels
        var currentLayerLabel = currentLayer.childNodes[0];
        _self.labelColorScheme.colorLabel(currentLayerLabel,tSeq);

      }
    };


    this.redrawEntire = function(){

      var tSeqs = [];

      for( var tSeq in this.seqs){
        tSeqs.push(this.seqs[tSeq].tSeq);
      }
      this.resetStage();
      this.addSequences(tSeqs);
    };


    // TODO: do we create memory leaks here?
    this.resetStage = function() {
      Utils.removeAllChilds(this.stage);
    }
    /*
     * EVENTS start here
     */

    this.onColumnSelect = function(pos){
      _self.log("column was clicked at pos"+ pos);
    }

    this.onRowSelect = function(id){
      _self.log("row was clicked at id"+ id);
    }

    this.onPositionClicked = function(id, pos){
      _self.log("seq " +id +" was clicked at " + pos);
    }

    this.onAnnotationClicked = function(){
      _self.log("not implemented yet");
    }

    this.onRegionSelected = function(){
      _self.log("not implemented yet");
    }

    this.onZoom = function(){
      _self.log("not implemented yet");
    }

    this.onScroll = function(){
      _self.log("not implemented yet");
    }

    this.onColorSchemeChanged = function(){
      _self.log("not implemented yet");
    }

    this.onDisplayEventChanged = function(){
      _self.log("not implemented yet");
    }


    this.console = undefined;

    this.setConsole = function(name){
      this.console = document.getElementById(name);
    };

    /*
     * some quick & dirty helper
     */
    this.log = function(msg){
      // append as a new line
      //   var msgEl = document.createElement("p");
      //    msgEl.textContent = msg;
      if( this.console !== "undefined" ){
        this.console.innerHTML = msg;
      }
      //  console.log(msg);
    };

  };

});
