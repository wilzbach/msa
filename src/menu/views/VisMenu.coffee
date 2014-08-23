view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
module.exports = ImportMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menuFile = new MenuBuilder("Vis. elements")
    menuFile.addNode "Toggle Marker", =>
      @g.vis.set "markers", ! @g.vis.get "markers"
    menuFile.addNode "Toggle Labels", =>
      @g.vis.set "labels", ! @g.vis.get "labels"
    menuFile.addNode "Toggle Sequences", =>
      @g.vis.set "sequences", ! @g.vis.get "sequences"
    menuFile.addNode "Toggle meta info", =>
      @g.vis.set "metacell", ! @g.vis.get "metacell"
    menuFile.addNode "Toggle bars", =>
      @g.vis.set "conserv", ! @g.vis.get "conserv"

    menuFile.addNode "Reset", =>
      @g.vis.set "labels", true
      @g.vis.set "sequences", true
      @g.vis.set "metacell", true
      @g.vis.set "conserv", true

    menuFile.addNode "Toggle mouseover events", =>
      @g.config.set "registerMouseEvents", !@g.config.get "registerMouseEvents"

    @el = menuFile.buildDOM()
    @
