var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(15,100);
opts.el = document.getElementById('msa_tree_menu');
opts.vis = {metacell: true, overviewbox: true};
//opts.columns = {hidden: [1,2,3]};
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.el = document.getElementById("msa_tree_menubar");
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);
m.addView("menu", defMenu);


// Tree
var tnt_theme_tree_collapse_nodes = function() {
    var tree_theme = function(tree_vis, div) {
        var newick = "(((((r0:9,r1:9, r7:5, r8:55)r10: 44, r2:34,r3:43)r4:52,r5:95, (r13: 77, r14: 50, r11:44, r12:88) r15: 70;)r6:215"
        var data = biojs.vis.tree.parse_newick(newick);
        tree_vis
            .data(data)
            .duration(500)
            .layout(biojs.vis.tree.tree.layout.vertical()
        .width(600)
        .scale(false));
        tree_vis.on_click (function(node){
            // sT
          var toggled = false;

          var childs = node.get_all_nodes();
          if(childs.length == 1){
            node.toggle();
            childs = node.get_all_nodes();
            toggled = true;
          }
          var ids = [];
          // reduce
          for(var i=1;i < childs.length;i++){
              ids.push(childs[i].data().name);
          }
          // convert to selection
          var sel = [];
          for(var i=0;i < ids.length;i++){
            sel.push(new msa.selection.rowsel({seqId:ids[i]}));
            var seq = m.seqs.where({id:ids[i]})[0];
            if(seq === undefined) continue
            if(toggled){
              seq.set('hidden', false);
            }else{
              seq.set('hidden', true);
            }
          }
          m.g.selcol.reset(sel);
          console.log(ids);
          console.log(node.data());

          if(!toggled){
            node.toggle();
          }

          tree_vis.update();
        });
        tree_vis
        .label().height(function(){return 50});
        // The visualization is started at this point
        tree_vis(div);
    };
    return tree_theme;
};

var tree_vis = biojs.vis.tree.tree();
var theme = tnt_theme_tree_collapse_nodes();
theme(tree_vis, document.getElementById("msa_tree_col2"));


m.g.on("row:click", function(data){
  var seqId = data.seqId;
  var root = tree_vis.root();
  var node = root.find_node_by_name(seqId);
  console.log(node.data());
  node.toggle();
  tree_vis.update();
});

// mini event system

m.onAll(function(eventName, data){
  log(eventName,data);
});

m.g.onAll(function(eventName, data){
  log(eventName,data);
});
m.g.selcol.on("all",function(eventName,data){
  log(eventName + " mod.", data.attributes);
});

var logger = document.getElementById("msa_tree_menu_console");
function log(eventName,data){
  if(data !== undefined){
    text = eventName  + " triggered with " + clean(data);
  } else{
    text = eventName  + " triggered";
  }
  message = document.createElement("div");
  message.textContent = text;
  if(logger.childNodes.length > 0){
    logger.insertBefore(message,logger.firstChild);
  }else{
    logger.appendChild(message);
  }
  if(logger.childNodes.length > 10){
    logger.removeChild(logger.lastChild);
  }
}

// prevent circular refs
function clean(obj){
  var o = {};
  if(typeof obj !== "object"){
    return obj;
  }
  for(var key in obj){
    if(typeof obj[key] !== 'object'){
      o[key] = obj[key];
    }
  }
  return JSON.stringify(o);
}


m.render();
