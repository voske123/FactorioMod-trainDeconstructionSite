local traindisassembly = util.table.deepcopy(data.raw["assembling-machine"]["trainassembly-machine"])

traindisassembly.type =            "furnace"
traindisassembly.name =            "traindisassembly-machine"
traindisassembly.minable_result =  "traindisassembly"

traindisassembly.crafting_catagories = {"traindisassembling"}

traindisassembly.result_inventory_size = 1
traindisassembly.source_inventory_size = 0

traindisassembly.fluid_boxes = -- give it an output pipe so it has a direction
{
  { -- NOTE: This output is always on a train track, so no worries that a pipe
    --       would empty the fluid that is comming out of this.
    production_type = "input",
    pipe_picture = nil,
    pipe_covers = nil, -- The pictures to show when another fluid box connects to this one.
    base_area = 0.01,  -- A base area of 1 will hold 100 units of water, 2 will hold 200, etc...
    base_level = 0,    -- the 'Starting height' of the fluidbox
    pipe_connections = {{ type="input", position = {0, 3.5} }}, -- output on the north side
    --secondary_draw_orders = { north = -1 }
  },
  off_when_no_fluid_recipe = false, -- makes sure it is showing the arrow
}

  

data:extend{
  traindisassembly,
}