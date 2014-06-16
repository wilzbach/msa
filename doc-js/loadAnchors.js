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
   // load anchors
    jQuery('h3').each(function(i, e) {

      var h3 = jQuery(e);
      var name = e.textContent.trim();
      name = convertToSlug(name);
      e.id = name;
      h3.append("<a name="+name+"> </a><a class='h-anchor' href='#" + name + "'> #</a>");
   });
  });
});
