// models
var SeqCollection = require("./model/SeqCollection");

// globals
var Colorator = require("./g/colorscheme");
var Columns = require("./g/columns");
var Config = require("./g/config");
var Package = require("./g/package");
var SelCol = require("./g/selection/SelectionCol");
var User = require("./g/user");
var Visibility = require("./g/visibility");
var VisOrdering = require("./g/visOrdering");
var Zoomer = require("./g/zoomer");

// MV from backbone
var boneView = require("backbone-childs");
var Eventhandler = require("biojs-events");

// MSA views
var Stage = require("./views/Stage");

// statistics
var Stats = require("stat.seqs");

// utils
var $ = require("jbone");
var FileHelper = require("./utils/file");
var TreeHelper = require("./utils/tree");
var ProxyHelper = require("./utils/proxy");

// opts is a dictionary consisting of
// @param el [String] id or reference to a DOM element
// @param seqs [SeqArray] Array of sequences for initlization
// @param conf [Dict] user config
// @param vis [Dict] config of visible views
// @param zoomer [Dict] display settings like columnWidth
module.exports = boneView.extend({

  initialize: function(data) {

    if (!(typeof data !== "undefined" && data !== null)) { data = {}; }
    // check for default arrays
    if (!(data.colorscheme != null)) { data.colorscheme = {}; }
    if (!(data.columns != null)) { data.columns = {}; }
    if (!(data.conf != null)) { data.conf = {}; }
    if (!(data.vis != null)) { data.vis = {}; }
    if (!(data.visorder != null)) { data.visorder = {}; }
    if (!(data.zoomer != null)) { data.zoomer = {}; }

    // g is our global Mediator
    this.g = Eventhandler.mixin({});

    // load seqs and add subviews
    this.seqs = this.g.seqs = new SeqCollection(data.seqs, this.g);

    // populate it and init the global models
    this.g.config = new Config(data.conf);
    this.g.package = new Package(this.g);
    this.g.selcol = new SelCol([],{g:this.g});
    this.g.user = new User();
    this.g.vis = new Visibility(data.vis, {model: this.seqs});
    this.g.visorder = new VisOrdering(data.visorder);
    this.g.zoomer = new Zoomer(data.zoomer,{g:this.g, model: this.seqs});

    // debug mode
    if (window.location.hostname === "localhost") {
      this.g.config.set("debug", true);
    }

    this._loadSeqs(data);

    // utils
    this.u = {};
    this.u.file = new FileHelper(this);
    this.u.proxy = new ProxyHelper({g: this.g});
    this.u.tree = new TreeHelper(this);

    if (this.g.config.get("eventBus") === true) {
      this.startEventBus();
    }

    if (this.g.config.get("dropImport")) {
      var events =
        {"dragover": this.dragOver,
        "drop": this.dropFile
        };
      this.delegateEvents(events);
    }

    if (data.importURL) {
      this.u.file.importURL(data.importURL, () => {
        return this.render();
      });
    }

    if (data.bootstrapMenu) {
      // pass menu configuration to defaultmenu
      if(data.menu){
        this.menuConfig = data.menu;
      }
      this.g.config.set("bootstrapMenu", true);
    }

    this.draw();
    // add models to the msa (convenience)
    return this.m();
  },

  _loadSeqs: function(data) {
    // stats
    var pureSeq = this.seqs.pluck("seq");
    this.g.stats = new Stats(this.seqs, {useGaps: true});
    this.g.stats.alphabetSize = this.g.config.get("alphabetSize");
    this.g.columns = new Columns(data.columns,this.g.stats);  // for action on the columns like hiding

    // depending config
    this.g.colorscheme = new Colorator(data.colorscheme, pureSeq, this.g.stats);

    // more init
    return this.g.zoomer.setEl(this.el, this.seqs);
  },

  // proxy to the utility package
  importURL: function() {
    return this.u.file.importURL.apply(this.u.file, arguments);
  },

  // add models to the msa (convenience)
  m: function() {
    var m = {};
    m.model = require("./model");
    m.selection = require("./g/selection/Selection");
    m.selcol = require("./g/selection/SelectionCol");
    m.view = require("backbone-viewj");
    m.boneView = require("backbone-childs");
    return this.m = m;
  },

  draw: function() {

    this.removeViews();

    this.addView("stage",new Stage({model: this.seqs, g: this.g}));
    this.el.setAttribute("class", "biojs_msa_div");

    // bootstraps the menu bar by default -> destroys modularity
    if (this.g.config.get("bootstrapMenu")) {
      var menuDiv = document.createElement('div');
      var wrapperDiv = document.createElement('div');
      if (!this.el.parentNode) {
        wrapperDiv.appendChild(menuDiv);
        wrapperDiv.appendChild(this.el);
      } else {
        this.el.parentNode.replaceChild(wrapperDiv, this.el);
        wrapperDiv.appendChild(menuDiv);
        wrapperDiv.appendChild(this.el);
      }

      var bootstrapOpts = {el: menuDiv,
        msa: this,
      };
      if(this.menuConfig){
        bootstrapOpts.menu = this.menuConfig;
      }
      var defMenu = new msa.menu.defaultmenu(bootstrapOpts);
      defMenu.render();
    }

    return $(window).on("resize", (e) => {
      var f = function() {
        return this.g.zoomer.autoResize();
      };
      return setTimeout(f.bind(this), 5);
    }
    );
  },

  dragOver: function(e) {
    // prevent the normal browser actions
    e.preventDefault();
    e.target.className = 'hover';
    return false;
  },

  dropFile: function(e) {
    e.preventDefault();
    var files = e.target.files || e.dataTransfer.files;
    this.u.file.importFiles(files);
    return false;
  },

  startEventBus() {
    var busObjs = ["config", "columns", "colorscheme", "selcol" ,"vis", "visorder", "zoomer"];
    return (() => {
      var result = [];
      for (var i = 0, key; i < busObjs.length; i++) {
        key = busObjs[i];
        result.push(this._proxyToG(key));
      }
      return result;
    })();
  },

  _proxyToG: function(key) {
    return this.listenTo(this.g[key], "all",function(name,prev,now,opts) {
      // suppress duplicate events
      if (name === "change") { return; }
      // backbone uses the second argument for the next value -> swap
      if ((typeof opts !== "undefined" && opts !== null)) {
        return this.g.trigger(key + ":" + name,now,prev,opts);
      } else {
        return this.g.trigger(key + ":" + name,now,prev);
      }
    });
  },

  render: function() {
    if (this.seqs === undefined || this.seqs.length === 0) {
      console.log("warning. empty seqs.");
    }
    this.renderSubviews();
    this.g.vis.set("loaded", true);
    return this;
  }
});