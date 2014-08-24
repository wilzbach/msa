view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
dom = require "../../utils/dom"

module.exports = OrderingMenu = view.extend

  initialize: ->
    @order = "ID"
    @el.style.display = "inline-block"

  setOrder: (order) ->
    @order = order
    @render()

  # TODO: make more generic
  render: ->
    menuOrdering = new MenuBuilder("Ordering")

    comps = @getComparators()
    for m in comps
      @_addNode menuOrdering,m

    el = menuOrdering.buildDOM()

    # TODO: make more efficient
    dom.removeAllChilds @el
    @el.appendChild el
    @

  _addNode: (menuOrdering, m) ->
    text = m.text
    style = {}
    if text is @order
      style.backgroundColor = "#77ED80"
    menuOrdering.addNode text, =>
      @model.comparator = m.comparator
      @model.sort()
      @setOrder m.text
    ,
      style: style

  getComparators: ->
    models = []

    models.push text: "ID", comparator: "id"

    models.push text: "ID Desc", comparator: (a, b) ->
        - a.get("id").localeCompare(b.get("id"))

    models.push text: "Label", comparator: "name"

    models.push text: "Label Desc", comparator: (a, b) ->
        - a.get("name").localeCompare(b.get("name"))

    models.push text: "Seq", comparator: "seq"

    models.push text: "Seq Desc", comparator: (a,b) ->
        - a.get("seq").localeCompare(b.get("seq"))

    models.push text: "Identity", comparator: "identity"

    models.push text: "Identity Desc", comparator: (seq) ->
        - seq.get "identity"

    return models
