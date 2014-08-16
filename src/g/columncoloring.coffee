    @.on "column:color", (data) =>
      columnGroup = data.target
      columnGroup.style.backgroundColor = "transparent"
      columnGroup.style.color = ""

    @msa.on "column:select", (data) =>
      columnGroup = data.target
      columnGroup.style.backgroundColor =
      Utils.rgba(Utils.hex2rgb("ff0000"),1.0)
      columnGroup.style.color = "white"


