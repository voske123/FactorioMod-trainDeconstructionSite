
local trainRecipeGroup = util.table.deepcopy(data.raw["recipe-category"]["trainassembling"])
trainRecipeGroup.name = "traindisassembling"

data:extend{
  trainRecipeGroup,
}

