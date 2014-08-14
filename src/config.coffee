Arrays = require "./utils/arrays"

# merges the default config
# with the user config
module.exports = (conf) ->

  defaultConf = {
    visibleElements: {
      labels: true, seqs: true, menubar: true, ruler: true,
      features: false,
      allowRectSelect: false,
      speed: false,
    },
    registerMoveOvers: false,
    autofit: true,
    keyevents: false,
    prerender: false,
  }

  if config?
    Arrays.recursiveDictFiller defaultConf, config
  else
    config = defaultConf
  return config
