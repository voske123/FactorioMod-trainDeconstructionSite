
--making the cargo wagon disassembling technology

local trainTechCargo = util.table.deepcopy(data.raw["technology"]["trainassembly-cargo-wagon"])

trainTechCargo.prerequisites = {trainTechCargo.name, "traindisassembly-automated-train-disassembling"}
trainTechCargo.name = "traindisassembly-cargo-wagon"
trainTechCargo.localised_name = {"technology-name.traindisassembly-cargo-wagon"}
trainTechCargo.localised_description = {"technology-description.traindisassembly-cargo-wagon"}

trainTechCargo.effects = {}
for _, trainRecipe in pairs ({
  "cargo-wagon",
}) do
  table.insert(trainTechCargo.effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end



--making the artillery wagon disassembling technology

local trainTechArty = util.table.deepcopy(data.raw["technology"]["trainassembly-artillery-wagon"])

trainTechArty.prerequisites = {trainTechArty.name, trainTechCargo.name}
trainTechArty.name = "traindisassembly-artillery-wagon"
trainTechArty.localised_name = {"technology-name.traindisassembly-artillery-wagon"}
trainTechArty.localised_description = {"technology-description.traindisassembly-artillery-wagon"}

trainTechArty.effects = {}
for _, trainRecipe in pairs ({
  "artillery-wagon",
}) do
   table.insert(trainTechArty.effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end



--making the locomotive disassembling tech

for _, trainRecipe in pairs ({
  "locomotive",
}) do
  table.insert(data.raw["technology"]["traindisassembly-automated-train-disassembling"].effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end



--making the fluid tech for fluid wagon

local trainTechFluid = util.table.deepcopy(data.raw["technology"]["fluid-wagon"])

trainTechFluid.prerequisites = {trainTechFluid.name, "traindisassembly-cargo-wagon"}
trainTechFluid.name = "traindisassembly-fluid-wagon"

trainTechFluid.effects = {}
for _, trainRecipe in pairs ({
  "fluid-wagon",
}) do
   table.insert(trainTechFluid.effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end

data:extend{
  trainTechCargo,
  trainTechArty,
  trainTechFluid
}