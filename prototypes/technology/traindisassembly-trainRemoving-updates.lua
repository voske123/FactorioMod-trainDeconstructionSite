local recipesToIgnore = {
  -- trainConstructionSite
  ["trainassembly"] = true,
  ["traindisassembly"] = mods["trainDeconstructionSite"] and true or nil,

  -- base game
  ["locomotive"     ] = true,
  ["cargo-wagon"    ] = true,
  ["fluid-wagon"    ] = true,
  ["artillery-wagon"] = true,
}

-- for mod compatibility we have to add these recipe unlocks to the tech tree
local trainsToIgnore = require("__trainConstructionSite__/prototypes/modded-trains-to-ignore")
local itemOverride   = require("__trainConstructionSite__/prototypes/modded-trains-item-override")
local recipeOverride   = require("__trainConstructionSite__/prototypes/modded-trains-recipe-override")
for _, trainType in pairs({
  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",
}) do
  -- For each type, we get all the different entities (ex: locomotive mk1, mk2, ...)
  for _, trainEntity in pairs(data.raw[trainType]) do
    -- For each entity, we get the item name. The item name is stored in minable.result
    if (not trainsToIgnore[trainType][trainEntity.name]) and trainEntity.minable and trainEntity.minable.result then

      local itemName   = itemOverride[trainType][trainEntity.name] or trainEntity.minable.result
      local recipeName = recipeOverride[trainType][itemName] or itemName -- assume the recipeName is the same as the item (otherwise we need to override it manualy)

      if not recipesToIgnore[recipeName] then
        log(recipeName)
        local fluidRecipeName = trainEntity.name .. "-parts[" .. trainType .. "]"

        -- now search all tech, to find the recipe that unlocks the item
        local technologyUnlockAdded = false
        for technologyName, technology in pairs(data.raw.technology) do
          for effectIndex, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipeName then
              -- make sure the fluidRecipe isn't present already
              local fluidRecipePresent = false
              for _, effect in pairs(technology.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == fluidRecipeName then
                  fluidRecipePresent = true
                end
              end

              -- if it is not present, we can add it
              if fluidRecipePresent then
                technologyUnlockAdded = true
              else
                table.insert(technology.effects, effectIndex + 1, {
                  type   = effect.type    ,
                  recipe = fluidRecipeName,
                })
                technologyUnlockAdded = true

                -- add new prerequisites
                if not technology.prerequisites then
                  technology.prerequisites = {}
                end
                for oldPrerequisite, newPrerequisite in pairs{
                  ["trainassembly-automated-train-assembling"] = "traindisassembly-automated-train-disassembling",
                  ["trainassembly-cargo-wagon"               ] = "traindisassembly-cargo-wagon",
                  ["fluid-wagon"                             ] = "traindisassembly-fluid-wagon",
                  ["trainassembly-artillery-wagon"           ] = "traindisassembly-artillery-wagon",
                } do
                  -- check to make sure it is not present yet
                  local prerequisitePresent = false
                  for prereqIndex, techPrerequisite in pairs(technology.prerequisites) do
                    if oldPrerequisite == techPrerequisite then
                      technology.prerequisites[prereqIndex] = newPrerequisite
                    end
                  end
                end
              end

            end
          end
        end

        -- if we didn't find it, we enable the recipe from the start
        if technologyUnlockAdded then
          --log(string.format("Unlocking train parts: %s (%s)", trainEntity.name, trainType))
        else
          log(string.format("Error unlocking train parts: %s (%s)", trainEntity.name, trainType))
          data.raw.recipe[fluidRecipeName].normal.enabled = true
        end

      end
    end
  end
end
