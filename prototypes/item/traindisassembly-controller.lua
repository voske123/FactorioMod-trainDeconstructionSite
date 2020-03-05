
local traincontroller = util.table.deepcopy(data.raw["item"]["traincontroller"])

traincontroller.name                  = "traincontroller-disassembly"
traincontroller.localised_name        = {"item-name.traincontroller", {[1] = "item-name.traindisassembly"}}
traincontroller.localised_description = {"item-description.traincontroller", {[1] = "item-name.traindisassembly"}}

traincontroller.icon                  = "__trainDeconstructionSite__/graphics/placeholders/icon.png"
traincontroller.icons                 = nil
traincontroller.icon_size             = 32
traincontroller.icon_mipmaps          = 1 

traincontroller.order                 = "d[trainbuilder]-c[controller]"

traincontroller.place_result          = traincontroller.name





data:extend{
  traincontroller,
}
