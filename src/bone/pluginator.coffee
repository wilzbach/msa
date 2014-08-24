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

view = require("../bone/view")

# pluginator mixin
# handles + order plugins
# gives a view a hierarchical / nested layout
# a view must have a `render` method
pluginator = view.extend

  # mix & shake
  #mixin: (view) ->
  #  exports = ["renderSubviews", "addView", "removeViews", "removeView", "remove"]
  #  for el in exports
  #    view[el] = pluginator[el]

  # TODO: maybe use jQuery detach
  # you need to call this method as the global view
  # removes all subviews
  # renders them out of the DOM
  # inserts them in one step
  renderSubviews: ->

    # empty the old container
    oldEl = @.el
    el = document.createElement "div"
    @setElement el
    frag = document.createDocumentFragment()

    if oldEl.parentNode?
      oldEl.parentNode.replaceChild @.el,oldEl

    # sort
    views = @_views()
    viewsSorted = sortViews views

    # render
    for key in viewsSorted
      view = views[key]
      view.render()
      node = views[key].el
      if node?
        frag.appendChild node

    # replace the current container with the new
    el.appendChild frag
    return el

  # adds a view
  # @param id [String] Id for later access
  # @param view [View] provides draw
  addView: (key,view) ->
    # init views (only once)
    views = @_views()

    unless view?
      throw "Invalid plugin. "
    # fallback for custom ordering
    #plug = {}
    #plug.obj = view
    view.ordering = key unless view.ordering?
    views[key] = view
    #plug.dom = document.createElement "div"
    #plug.trigger "draw", { target: dom}

  # destroys all subviews
  # TODO: check for memory leaks
  removeViews: ->
    views = @_views()
    for key,el of @.views
      el.undelegateEvents()
      el.unbind()
      el.removeViews() if el.removeViews?
      el.remove()

    @.views = {}

  # removes a single view
  removeView: (key) ->
    views = @_views()
    views[key].remove()
    delete views[key]

  # returns a view for the key
  getView: (key) ->
    views = @_views()
    return views[key]

  # Removes the view by emptying, releasing all content, and orphaning the container:
  # The region is no longer usable after being removed.
  remove: ->
    @removeViews()
    view.remove.apply @
    #ViewPrototype.remove.apply @

  _views : ->
    @.views = {} unless @.views?
    @.views

module.exports = pluginator
