
local trainRecipeGroup = util.table.deepcopy(data.raw["recipe-category"]["chemistry"])
trainRecipeGroup.name = "traindisassembling"

data:extend{
  trainRecipeGroup    ,
}

