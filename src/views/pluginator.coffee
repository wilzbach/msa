Utils = require "../utils/dom"

# sorts the views after their given ordering
# @returns sorted list of keys (of the plugins)
sortViews = (views) ->
    # sort plugs
    plugsSort = []
    plugsSort.push key for key of views
    plugsSort.sort (a,b) =>
        nameA = views[a].ordering
        nameB = views[b].ordering
        return -1 if nameA < nameB
        return 1  if nameA > nameB
        0
    return plugsSort

# pluginator mixin
# handles + order plugins
# gives a view a hierarchical / nested layout
# a view must have a `render` method
pluginator =

  # mix & shake
  mixin: (view) ->
    exports = ["renderSubviews", "addView"]
    for el in exports
      view[el] = pluginator[el]

  # TODO: maybe use jQuery detach
  # you need to call this method as the global view
  # removes all subviews
  # renders them out of the DOM
  # inserts them in one step
  renderSubviews: ->

    Utils.removeAllChilds @el

    frag = document.createDocumentFragment()
    # sort
    viewsSorted = sortViews @views
    # render
    for key in viewsSorted
      view = @views[key]
      view.render()

      node = view.el
      if node
        frag.appendChild node

    # replace the current container with the new
    @el.appendChild frag

  # adds a view
  # @param id [String] Id for later access
  # @param view [View] provides draw
  addView: (key,view) ->
    # init views (only once)
    @views = {} unless @.views?

    unless view?
      throw "Invalid plugin. "
    # fallback for custom ordering
    #plug = {}
    #plug.obj = view
    view.ordering = key unless view.ordering?
    @views[key] = view
    #plug.dom = document.createElement "div"
    #plug.trigger "draw", { target: dom}

#  # TODO: deprecated
#  # redraws a special plugin
#  # @param id [String] Id of the plugin
#  redrawPlugin: (key) ->
#    plug = @plugs[key]
#    oldDOM = plug.dom
#
#    # new DOM
#    plug.dom = document.createElement "div"
#    plug.obj.trigger "draw", {target: plug.dom}
#
#    # better use container than parentNode
#    oldDOM.parentNode.replaceChild plug.dom, oldDOM

module.exports = pluginator
