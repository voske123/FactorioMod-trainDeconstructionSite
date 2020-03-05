
-- the placeable entity is linked to this item
local traindisassembly = util.table.deepcopy(data.raw["item"]["trainassembly"])

traindisassembly.name  = "traindisassembly"
traindisassembly.localised_name = {"item-name.traindisassembly"}
traindisassembly.localised_description = {"item-description.traindisassembly"}

traindisassembly.icon = "__trainDeconstructionSite__/graphics/placeholders/icon.png"
traindisassembly.icons = nil
traindisassembly.icon_size = 32

traindisassembly.order = "d[trainbuilder]-b[builder]"

traindisassembly.place_result = "traindisassembly-placeable" -- the name of the placable entity




data:extend{
  traindisassembly,
}
