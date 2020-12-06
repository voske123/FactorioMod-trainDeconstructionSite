local traindisassembly = util.table.deepcopy(data.raw["assembling-machine"]["trainassembly-machine"])

traindisassembly.type =            "furnace"
traindisassembly.name =            "traindisassembly-machine"
traindisassembly.minable.result =  "traindisassembly"
traindisassembly.placeable_by = {item=traindisassembly.minable.result, count= 1}

-- copy localisation from the item
traindisassembly.localised_name = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_name)
traindisassembly.localised_description = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].localised_description)

-- copy the icon over from the item
traindisassembly.icon = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon)
traindisassembly.icons = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icons)
traindisassembly.icon_size = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon_size)
traindisassembly.icon_mipmaps = util.table.deepcopy(data.raw["item"][traindisassembly.minable.result].icon_mipmaps)

traindisassembly.fluid_boxes = -- give it an output pipe so it has a direction
{
  { -- NOTE: This input is always on a train track, so no worries that a pipe
    --       would empty the fluid that is comming in of this.
    production_type = "input",
    pipe_picture = nil,
    pipe_covers = nil, -- The pictures to show when another fluid box connects to this one.
    base_area = 0.01,  -- A base area of 1 will hold 100 units of water, 2 will hold 200, etc...
    base_level = 100,    -- the 'Starting height' of the fluidbox
    pipe_connections = {{ type="input", position = {0, 3.5} }}, -- input on the south side
    --secondary_draw_orders = { north = -1 }
  },
  off_when_no_fluid_recipe = false, -- makes sure it is showing the arrow
}

traindisassembly.crafting_categories = {"traindisassembling"}

traindisassembly.result_inventory_size = 1
traindisassembly.source_inventory_size = 0

data:extend{
  util.table.deepcopy(traindisassembly),
}

-- now create the selector
traindisassembly.name = traindisassembly.name .. "-recipe-selector"

for _,flag in pairs{
  "player-creation"  ,
  "placeable-enemy"  ,
  "placeable-neutral",
  "placeable-player" ,
} do
  for flagIndex,f in pairs(traindisassembly.flags) do
    if flag == f then
      table.remove(traindisassembly.flags, flagIndex)
    end
  end
end
for _,flag in pairs{
  "hidden"                     ,
  "hide-alt-info"              ,
  "not-blueprintable"          ,
  "not-deconstructable"        ,
  "no-copy-paste"              ,
  "not-selectable-in-game"     ,
  "not-upgradable"             ,
  "not-flammable"              ,
  "no-automated-item-insertion",
} do
  table.insert(traindisassembly.flags, flag)
end

traindisassembly.selection_box = nil
traindisassembly.collision_mask = {}
traindisassembly.collision_box = {{-.49, -.49}, {.49, .49}}

traindisassembly.fluid_boxes[1].pipe_connections[1].position = {0, -1}

traindisassembly.energy_source.render_no_power_icon = false
traindisassembly.energy_source.render_no_network_icon = false

traindisassembly.animation =
{
  filename = "__core__/graphics/empty.png",
  priorit = "very-low",
  width = 1,
  height = 1,
  frame_count = 1,
}
traindisassembly.working_visualisations = nil

data:extend{
  traindisassembly,
}