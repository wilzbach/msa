
    @.on "label:color", (data) =>
      labelGroup = data.target
      if not labelGroup.color?
        color = {}
        color.r = Math.ceil(Math.random() * 255)
        color.g = Math.ceil(Math.random() * 255)
        color.b = Math.ceil(Math.random() * 255)
        labelGroup.color = color
      labelGroup.color = Utils.hex2rgb "ffffff"
      labelGroup.style.backgroundColor = Utils.rgba(labelGroup.color, 0.5)

    @msa.on "label:select", (data) =>
      labelGroup = data.target
      rect = labelGroup.children[0]
      label = labelGroup.children[1]
      labelGroup.style.textColor = "white"
      labelGroup.color = Utils.hex2rgb "ff0000"
      labelGroup.style.backgroundColor = Utils.rgba(labelGroup.color, 1.0)
