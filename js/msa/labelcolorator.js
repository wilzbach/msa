define(["./utils"], function(Utils){
	return function(){


  this.colorLabel =function(labelGroup, tSeq){

    if( typeof labelGroup.color === "undefined"){
      var color = {};
      color.r = Math.ceil(Math.random() * 255);
      color.g = Math.ceil(Math.random() * 255);
      color.b = Math.ceil(Math.random() * 255);

      labelGroup.color = color;
    }

    labelGroup.style.backgroundColor= Utils.rgba(labelGroup.color, 0.5); 
  };

  this.colorSelectedLabel =function(labelGroup, tSeq){

    var rect = labelGroup.children[0];
    var label = labelGroup.children[1];

    labelGroup.style.textColor= 'white'; 
    labelGroup.style.backgroundColor= Utils.rgba(labelGroup.color, 1.0); 

    //  rect.setShadowOffset({x:5, y:5});
    //  rect.setShadowOpacity(0.6);
  };



};

});
