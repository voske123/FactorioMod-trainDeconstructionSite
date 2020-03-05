
local trainControllerDisassembly = util.table.deepcopy(data.raw["recipe"]["traincontroller"])

trainControllerDisassembly.name = "traincontroller-disassembly"

trainControllerDisassembly.normal.results[1].name = "traincontroller-disassembly"



data:extend{
  trainControllerDisassembly,

}
