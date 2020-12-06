
local traindisassembly = util.table.deepcopy(data.raw["locomotive"]["trainassembly-placeable"])
traindisassembly.name = "traindisassembly-placeable"

traindisassembly.minable.result = "traindisassembly" -- name of the item

-- copy localisation from the item
traindisassembly.localised_name = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_name)
traindisassembly.localised_description = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_description)

-- copy the icon over from the item
traindisassembly.icon = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon)
traindisassembly.icons = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icons)
traindisassembly.icon_size = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon_size)
traindisassembly.icon_mipmaps = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon_mipmaps)

data:extend{
  traindisassembly,
}
