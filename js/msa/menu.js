define([], function(){
return function(msa){
  var _self = this;

  this.menu = document.createElement("div");
  this.menu.className = "biojs_msa_menubar";
  this.menu.id = msa.globalID + "_menubar"; 

  this.msa = msa;

  this.getMenuDOM = function(){
    return this.menu;
  };

  this.deleteMenu = function(){
    BioJS.Utils.removeAllChilds(this.menu);
  };

};

BioJS.MSA.DefaultMenu  = function(msa){

  this.menuCreator = new BioJS.MSA.MenuCreator();

  this.createMenu = function(){
    this.menu.appendChild(this._createFileSchemeMenu());
    this.menu.appendChild(this._createColorSchemeMenu());
    this.menu.appendChild(this._createOrderingMenu());
    this.menu.appendChild(document.createElement("p"));
  }

  this._createFileSchemeMenu = function(){

    var menuFile = menuCreator.newMenu("Settings");

    menuFile.addNode("Hide Marker", function(){
      if(_self.msa.visibleElements.ruler === true){
        $(this).children().first().text("Display Marker");
        _self.msa.visibleElements.ruler = false;
      }else{
        $(this).children().first().text("Hide Marker");
        _self.msa.visibleElements.ruler = true;
      }
      _self.msa.orderSeqsAfterScheme();
    });

    menuFile.addNode("Hide Labels", function(){
      if(_self.msa.visibleElements.labels === true){
        _self.msa.visibleElements.labels = false;
        $(this).children().first().text("Display Labels");
      }else{
        _self.msa.visibleElements.labels = true;
        $(this).children().first().text("Hide Labels");
      }
      _self.msa.redrawEntire();
    });

    menuFile.addNode("Hide Menu", function(){
      _self.deleteMenu();
    });

    return menuFile.buildDOM();
  }

  this._createColorSchemeMenu = function(){

    var menuColor = menuCreator.newMenu("Color scheme");

    menuColor.addNode("Zappo", function(){
      _self.msa.colorscheme.setScheme('zappo');
      _self.msa.redraw();
    });

    menuColor.addNode("Taylor", function(){
      _self.msa.colorscheme.setScheme('taylor');
      _self.msa.redraw();
    });

    menuColor,addNode("Hydrophobicity", function(){
      _self.msa.colorscheme.setScheme('hydrophobicity');
      _self.msa.redraw();
    });

    return menuColor.createDOM();
  }

  this._createOrderingMenu = function(){

    var menuOrdering = menuCreator.newMenu("Ordering");

    menuOrdering.addNode("ID", function(){
      _self.msa.orderSeqsAfterScheme('numeric');
    });

    menuOrdering.addNode("ID Desc", function(){
      _self.msa.orderSeqsAfterScheme('reverse-numeric');
    });

    menuOrdering.addNode("Label", function(){
      _self.msa.orderSeqsAfterScheme('alphabetic');
    });

    menuOrdering.addNode("Label Desc",function(){
      _self.msa.orderSeqsAfterScheme('reverse-alphabetic');
    });

    return menuOrdering.createDOM();
  }

}






_createOrderingMenu = function(){

  this.menuOrderingDiv = jQuery('<div id="dropdown-2" class="dropdown dropdown-tip"></div>' );
  this.menuOrderingUl = jQuery('<ul class="dropdown-menu"></ul>');
  this.menuOrderingElements = [];

  var numeric = jQuery('<li><a href="#">ID</a></li>');
  numeric.click(function(){
    _self.msa.orderSeqsAfterScheme('numeric');
  });
  this.menuOrderingUl.append(numeric);

  var numericr= jQuery('<li><a href="#">ID Desc</a></li>');
  numericr.click(function(){
    _self.msa.orderSeqsAfterScheme('reverse-numeric');
  });
  this.menuOrderingUl.append(numericr);

  var alphabetic= jQuery('<li><a href="#">Label</a></li>');
  alphabetic.click(function(){
    _self.msa.orderSeqsAfterScheme('alphabetic');
  });
  this.menuOrderingUl.append(alphabetic);

  var alphabeticr= jQuery('<li><a href="#">Label Desc</a></li>');
  alphabeticr.click(function(){
    _self.msa.orderSeqsAfterScheme('reverse-alphabetic');
  });
  this.menuOrderingUl.append(alphabeticr);

  this.menuOrderingDiv.append(this.menuOrderingUl);

  this.menu.appendChild(this.menuOrderingDiv[0]);
  var aLink = jQuery('<a href="#" data-dropdown="#dropdown-2" class="alink">Ordering</a>');
  this.menu.appendChild(aLink[0]);
}

});
