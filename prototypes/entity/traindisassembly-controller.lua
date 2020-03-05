
local traincontroller = util.table.deepcopy(data.raw["train-stop"]["traincontroller"])

traincontroller.name = "traincontroller-disassembly"

traincontroller.minable.result = "traincontroller-disassembly"

traincontroller.localised_name = util.table.deepcopy(data.raw["item"][traincontroller.minable.result].localised_name)
traincontroller.localised_description = util.table.deepcopy(data.raw["item"][traincontroller.minable.result].localised_description)

traincontroller.icon = data.raw["item"][traincontroller.minable.result].icon
traincontroller.icon_size = data.raw["item"][traincontroller.minable.result].icon_size
traincontroller.icons = util.table.deepcopy(data.raw["item"][traincontroller.minable.result].icons)
traincontroller.icon_mipmaps = data.raw["item"][traincontroller.minable.result].icon_mipmaps

-- hidden entities --
local traincontrollerSignal = util.table.deepcopy(data.raw["rail-signal"]["traincontroller-signal"])

traincontrollerSignal.name = traincontroller.name .. "-signal"

traincontrollerSignal.icon = traincontroller.icon
traincontrollerSignal.icon_size = traincontroller.icon_size
traincontrollerSignal.icons = util.table.deepcopy(traincontroller.icons)
traincontrollerSignal.icon_mipmaps = traincontroller.icon_mipmaps


local traincontrollerMapview = util.table.deepcopy(data.raw["simple-entity-with-force"]["traincontroller-mapview"])

traincontrollerMapview.name = traincontroller.name .. "-mapview"



data:extend{
  traincontroller,
  traincontrollerSignal,
  traincontrollerMapview,
}
