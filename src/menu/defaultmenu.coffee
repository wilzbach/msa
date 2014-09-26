boneView = require("backbone-childs")

# menu views
ImportMenu = require "./views/ImportMenu"
FilterMenu = require "./views/FilterMenu"
SelectionMenu = require "./views/SelectionMenu"
VisMenu = require "./views/VisMenu"
ColorMenu = require "./views/ColorMenu"
OrderingMenu = require "./views/OrderingMenu"
ExtraMenu = require "./views/ExtraMenu"
ExportMenu = require "./views/ExportMenu"
HelpMenu = require "./views/HelpMenu"

# this very basic menu demonstrates calls to the MSA component
module.exports = MenuView = boneView.extend

  initialize: (data) ->
    @msa = data.msa

    @addView  "10_import", new ImportMenu model: @msa.seqs, g:@msa.g
    @addView  "20_filter", new FilterMenu model: @msa.seqs, g:@msa.g
    @addView  "30_selection", new SelectionMenu model: @msa.seqs, g:@msa.g
    @addView  "40_vis", new VisMenu model: @msa.seqs, g:@msa.g
    @addView  "50_color", new ColorMenu model: @msa.seqs, g:@msa.g
    @addView  "60_ordering", new OrderingMenu model: @msa.seqs, g:@msa.g
    @addView  "70_extra", new ExtraMenu model: @msa.seqs, g:@msa.g
    @addView  "80_export", new ExportMenu model: @msa.seqs, g:@msa.g, msa:@msa
    @addView  "90_help", new HelpMenu  g:@msa.g

  render: ->
    @renderSubviews()
    # other
    @el.setAttribute "class", "biojs_msa_menubar"
    @el.appendChild document.createElement("p")
