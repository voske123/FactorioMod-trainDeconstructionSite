local itemOverride   = require("__trainConstructionSite__/prototypes/modded-trains-item-override")

-- For each train-like entity we want to create a recipe so we can put this in
-- our trainbuilding to make an actual train on the tracks. To get the fluidname
-- we require the itemname. To aquire the itemname we get the entity.minable.result.
-- For this we start to iterate over all tine train types
local trainsToIgnore = require("__trainConstructionSite__/prototypes/modded-trains-to-ignore")
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

      local itemName = itemOverride[trainType][trainEntity.name] or trainEntity.minable.result

      -- now that we have the itemname we can create the fluid recipe.
      data:extend{
        {
          type = "recipe",
          name = trainEntity.name .. "-parts[" .. trainType .. "]",
          category = "traindisassembling",
          expensive = nil,
          normal =
          {
            enabled = false,
            energy_required = 15,
            ingredients =
            {
              {
                type    = "fluid",
                name    = itemName .. "-fluid",
                amount  = 1,
              },
            },
            results =
            {
              {itemName, 1},
            },
          },
        }
      }
     
    end
  end
end
