// this displays the source code from the snippet
// due to browser restriction we have to download the file again as 'text' object
var loadBoxes = function(){
  $(document).ready(function() {

      // load the text to a 
      jQuery('.row script').each(function(i, e) {

        var row = jQuery(e).parent();
        var codePos =row.find(".source-code").first();
        codePos.append(jQuery('<pre class="hljs-js"><code></code></pre>'));
        var url = e.src;

        var codePosDOM = codePos[0];

        $.ajax({type: "GET", url: url, dataType: "text" }).done(function( data ) {
          codePos = jQuery(codePosDOM);
          codeBox =codePos.find("pre code").first();
          codeBox.text(jQuery.trim(data));
          hljs.highlightBlock(codeBox[0]);
        })
        .fail(function(){
          console.log("couldn't retrieve url"); 
        });

      });
    });
};


if (typeof define === 'function' && define.amd) {
  require(["jquery"], function(jQuery){
      loadBoxes(jQuery);
      });
}
else{
  loadBoxes(jQuery);
}
