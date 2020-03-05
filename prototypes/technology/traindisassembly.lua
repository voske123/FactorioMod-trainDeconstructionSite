
local trainTechDeconstructor = util.table.deepcopy(data.raw["technology"]["trainassembly-automated-train-assembling"])

trainTechDeconstructor.name = "traindisassembly-automated-train-disassembling"
trainTechDeconstructor.effects = {}
trainTechDeconstructor.localised_name = {"technology-name.trainTechDeconstructor"}
trainTechDeconstructor.localised_description = {"technology-description.trainTechDeconstructor"}



for _, recipeName in pairs{
  "traindisassembly",
} do
  table.insert(trainTechDeconstructor.effects,
  {
    type = "unlock-recipe",
    recipe = recipeName,
  })
end



data:extend{ -- add train technology to tech tree
  trainTechDeconstructor,
}
