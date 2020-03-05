
local traindisassembly = util.table.deepcopy(data.raw["recipe"]["trainassembly"])

traindisassembly.name = "traindisassembly"

traindisassembly.normal.results[1].name = "traindisassembly"



data:extend{
  traindisassembly,

}