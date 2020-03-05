
--making the cargo wagon technology and unlocking the wagon parts and fluid

local trainTechCargo = data.raw["technology"]["trainassembly-cargo-wagon"]

table.insert(trainTechCargo.prerequisites, "traindisassembly-automated-train-disassembling")

for _, trainRecipe in pairs ({
  "cargo-wagon",
}) do
  table.insert(trainTechCargo.effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end



--making the artillery wagon technology and unlocking the wagon parts and fluid

local trainTechArty = data.raw["technology"]["trainassembly-artillery-wagon"]

table.insert(trainTechArty.prerequisites, "traindisassembly-automated-train-disassembling")

for _, trainRecipe in pairs ({
  "artillery-wagon",
}) do
   table.insert(trainTechArty.effects,
  {
    type = "unlock-recipe",
    recipe = trainRecipe .. "-parts[" .. trainRecipe .. "]",
  })
end



--making the locomotive fluid tech

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

for techName, techPrototype in pairs(data.raw["technology"]) do
  if techPrototype.effects then
    for techEffectIndex, techEffect in pairs(techPrototype.effects) do
      if techEffect.type == "unlock-recipe" then
        for _, wagonName in pairs({
          "fluid-wagon",
        }) do
          if techEffect.recipe == wagonName then
            table.insert(data.raw["technology"][techName].effects, techEffectIndex + 1,
            {
              type = "unlock-recipe",
              recipe = wagonName .. "-parts[" .. wagonName .. "]",
            })
          end
        end
      end
    end
  end
end

table.insert(data.raw["technology"]["fluid-wagon"].prerequisites, "traindisassembly-automated-train-disassembling")
