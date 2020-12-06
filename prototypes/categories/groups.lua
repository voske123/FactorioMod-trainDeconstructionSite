local transportRailway = util.table.deepcopy(data.raw["item-subgroup"]["trainparts-fluid"])
transportRailway.name = "trainparts-parts"
transportRailway.order = "f"

data:extend{
  transportRailway
}