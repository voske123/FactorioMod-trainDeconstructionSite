
local traindisassembly = util.table.deepcopy(data.raw["locomotive"]["trainassembly-placeable"])
traindisassembly.name = "traindisassembly-placeable"

traindisassembly.minable.result = "traindisassembly" -- name of the item

-- copy localisation from the item
traindisassembly.localised_name = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_name)
traindisassembly.localised_description = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_description)

-- copy the icon over from the item
traindisassembly.icon = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon)
traindisassembly.icons = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icons)
traindisassembly.icon_size = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon_size)

-- graphics
traindisassembly.pictures =
{
  layers =
  {
    {
      width = 256,
      height = 256,
      direction_count = 4,
      --allow_low_quality_rotation = true,
      frame_count = 1,
      line_length = 4,
      lines_per_file = 1,
      filename = "__trainDeconstructionSite__/graphics/placeholders/6x6-4.png",
      --[[
      filenames =
      {
        "__trainDeconstructionSite__/graphics/placeholders/6x6.png",
        "__trainDeconstructionSite__/graphics/placeholders/6x6.png",
        "__trainDeconstructionSite__/graphics/placeholders/6x6.png",
        "__trainDeconstructionSite__/graphics/placeholders/6x6.png",
      },
      ]]--
      hr_version = nil,
    },
    --[[{
      width = 82,
      height = 82,
      direction_count = 4,
      --allow_low_quality_rotation = true,
      frame_count = 1,
      line_length = 4,
      lines_per_file = 1,
      filename = "__trainDeconstructionSite__/graphics/placeholders/directions.png",
      --[[
      filenames =
      {
        "__trainDeconstructionSite__/graphics/placeholders/direction_north.png",
        "__trainDeconstructionSite__/graphics/placeholders/direction_east.png",
        "__trainDeconstructionSite__/graphics/placeholders/direction_south.png",
        "__trainDeconstructionSite__/graphics/placeholders/direction_west.png",
      },
      ]]--[[
      hr_version = nil,
    },
    ]]--
  },
}

data:extend{
  traindisassembly,
}
