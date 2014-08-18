view = require("../bone/view")
MenuBuilder = require "../menu/menubuilder"

module.exports = MetaView = view.extend

  className: "biojs_msa_metaview"

  initialize: (data) ->
    @g = data.g

  events:
    click: "_onclick"
    mousein: "_onmousein"
    mouseout: "_onmouseout"

  render: ->
    @el.style.display = "inline-block"

    width = @g.zoomer.get "metaWidth"
    @el.style.width = width / 2
    @el.style.paddingRight = width / 2


    # TODO: this menu builder is just an example how one could customize this
    # view
    menu = new MenuBuilder(">")
    menu.addNode "Uniprot",(e) =>
      @g.colorscheme.set "scheme","zappo"
    @el.appendChild menu.buildDOM()

    @el.style.height = "#{@g.zoomer.get "rowHeight"}px"
    @el.style.float = "left"
    @el.style.cursor = "pointer"

  _onclick: (evt) ->
    @g.trigger "meta:click", {seqId: @model.get "id", evt:evt}

  _onmousein: (evt) ->
    @g.trigger "meta:mousein", {seqId: @model.get "id", evt:evt}

  _onmouseout: (evt) ->
    @g.trigger "meta:mouseout", {seqId: @model.get "id", evt:evt}
