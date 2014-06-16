// this displays the source code from the snippet
// due to browser restriction we have to download the file again as 'text' object

function convertToSlug(Text)
{
    return Text
        .toLowerCase()
        .replace(/[^\w ]+/g,'')
        .replace(/ +/g,'-')
        ;
}

require(["jquery"], function(jQuery){
  jQuery(document).ready(function() {

    // load the text to a 
    jQuery('.row script').each(function(i, e) {

      var row = jQuery(e).parent();
      var codePos =row.find(".source-code").first();
      codePos.append(jQuery('<pre class="hljs-js"><code></code></pre>'));
      var url = e.src;

      var codePosDOM = codePos[0];

      var xhr = new XMLHttpRequest();
      xhr.open("GET", url, true);
      xhr.onreadystatechange = function(){
        if(xhr.readyState === 4 && xhr.status === 200){
          var data = xhr.responseText;
          var codePosInner = jQuery(codePosDOM);
          var codeBox =codePosInner.find("pre code").first();
          codeBox.text(jQuery.trim(data));
          hljs.highlightBlock(codeBox[0]);
        }
      };
      xhr.send();


    });

   // load anchors
    jQuery('h3').each(function(i, e) {

      var h3 = jQuery(e);
      var name = e.textContent.trim();
      name = convertToSlug(name);
      e.id = name;
      h3.append("<a name="+name+"></a><a class='h-anchor' href='#" + name + "'>#</a>");
   });
  });
});
