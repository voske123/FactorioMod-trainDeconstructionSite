require 'util'
require("__LSlib__/LSlib")

-- Create class
Traincontroller.Demolisher.Conductor = {}

--------------------------------------------------------------------------------
-- Initiation of the class
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:onInit()
  if not global.TC_data.Demolisher.Conductor then
    global.TC_data.Demolisher.Conductor = self:initGlobalData()
  end
end



-- Initiation of the global data
function Traincontroller.Demolisher.Conductor:initGlobalData()
  local Conductor = {
    ["version"      ] = 1, -- version of the global data

    ["pathingTrains"] = { -- keep track of all trains pathing (+arriving) to a demolisher controller
    },
  }

  return util.table.deepcopy(Conductor)
end




--------------------------------------------------------------------------------
-- Setter functions to alter data into the data structure
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:addArrivingTrain(trainEntity, trainController)
  local trainFrontEntity = trainEntity.speed >= 0 and trainEntity.front_stock or trainEntity.back_stock
  local trainSpeed = trainEntity.speed

  local trainArrivingPosition = trainFrontEntity.position
  local trainDemolishingPosition = Traincontroller:getTrainDemolishingPosition(trainController)
  local trainBreakingDistanceX = trainArrivingPosition.x - trainDemolishingPosition.x
  local trainBreakingDistanceY = trainArrivingPosition.y - trainDemolishingPosition.y
  local trainBreakingDistance = trainBreakingDistanceX * trainBreakingDistanceX + trainBreakingDistanceY * trainBreakingDistanceY
  table.insert(global.TC_data.Demolisher.Conductor["pathingTrains"], {
    ["trainEntity"                   ] = trainFrontEntity,
    ["trainDemolishingPosition"      ] = trainDemolishingPosition,
    ["trainDemolishingIndex"         ] = Traincontroller:getTrainDemolisherIndex(trainController),
    ["initialArrivingSpeed"          ] = trainSpeed,
    ["initialArrivingDistanceSquared"] = trainBreakingDistance,
    ["currentArrivingDistanceSquared"] = trainBreakingDistance
  })
  if not global.TC_data.Demolisher["onTickActive"] then
    Traincontroller.Demolisher:activateOnTick()
  end

  -- todo: set in manual mode with current speed
  trainEntity.manual_mode = true
  trainEntity.speed = trainSpeed
end



function Traincontroller.Demolisher.Conductor:removeArrivingTrain(pathingTrainIndex)
  table.remove(global.TC_data.Demolisher.Conductor["pathingTrains"], pathingTrainIndex)
end



--------------------------------------------------------------------------------
-- Getter functions to extract data from the data structure
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:getPathingTrains()
  return global.TC_data.Demolisher.Conductor["pathingTrains"]
end



function Traincontroller.Demolisher.Conductor:hasPathingTrains()
  return #self:getPathingTrains() > 0
end



--------------------------------------------------------------------------------
-- Behaviour functions
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:calculateArrivingSpeed(squaredDistance, initialSquaredDistance, initialSpeed)
  --return ( 1 - math.cos(squaredDistance/initialSquaredDistance*math.pi/2) ) * initialSpeed
  --return (0.45 * math.cos(math.pi * (squaredDistance/initialSquaredDistance - 1)) + 0.55) * initialSpeed
  return math.max(math.sqrt(squaredDistance/initialSquaredDistance), 0.135) * initialSpeed
end



function Traincontroller.Demolisher.Conductor:monitorArrivingTrain(arrivingTrain)
  -- Monitors an arriving train.
  -- Returns true if train is arrived at destination
  local arrivingTrainEntity = arrivingTrain.trainEntity
  local arrivingTrainPosition = arrivingTrainEntity.position
  local demolisherPosition = arrivingTrain.trainDemolishingPosition
  local distanceX = demolisherPosition.x - arrivingTrainPosition.x
  local distanceY = demolisherPosition.y - arrivingTrainPosition.y
  local distanceSquared = distanceX * distanceX + distanceY * distanceY

  if distanceSquared <= arrivingTrain["currentArrivingDistanceSquared"] then
    -- STEP 1: the train is getting closer to destination
    arrivingTrainEntity.train.speed = Traincontroller.Demolisher.Conductor:calculateArrivingSpeed(
      distanceSquared, arrivingTrain["initialArrivingDistanceSquared"], arrivingTrain["initialArrivingSpeed"])
    arrivingTrain["currentArrivingDistanceSquared"] = distanceSquared
    return false
  end

  -- STEP 2: the train arrived (past) the destination,
  --         check if the train can be deconstructed
  local trainCarriages = arrivingTrainEntity.train.carriages
  if #trainCarriages > #TrainDisassembly:getTrainDemolisher(arrivingTrain["trainDemolishingIndex"]) then
    -- train is too long... leave the train be where it is now, and add some flying text to it...
    arrivingTrainEntity.train.speed = 0
    game.print("TODO: cannot be deconstructed line 114")
    return true 
  end

  -- STEP 3: the train can be deconstructed,
  --         now we can put it in the right place
  local trainCarriagesToCreate = {}
  for _, trainCarriage in pairs(trainCarriages) do
    local demolisherMachineEntity = arrivingTrainEntity.surface.find_entities_filtered{
      name     = TrainDisassembly:getMachineEntityName(),
      --force    = trainCarriage.force,
      position = trainCarriage.position,
      limit    = 1,
    }[1]
    if demolisherMachineEntity then
      table.insert(trainCarriagesToCreate, {
        name                      = trainCarriage.name,
        position                  = demolisherMachineEntity.position,
        direction                 = LSlib.utils.directions.orientationTo4WayDirection(trainCarriage.orientation),
        force                     = trainCarriage.force,
        player                    = trainCarriage.last_user,
        raise_built               = true,
        create_build_effect_smoke = false,
        snap_to_train_stop        = false,
        content                   = {
          fuel            = trainCarriage.type == "locomotive"      and trainCarriage.get_fuel_inventory().get_contents()                                  or {},
          item_cargo      = trainCarriage.type == "cargo-wagon"     and trainCarriage.get_inventory(defines.inventory.cargo_wagon).get_contents()          or {},
          fluid_cargo     = trainCarriage.type == "fluid-wagon"     and trainCarriage.get_fluid_contents()                                                 or {},
          artillery_cargo = trainCarriage.type == "artillery-wagon" and trainCarriage.get_inventory(defines.inventory.artillery_wagon_ammo).get_contents() or {},
        }
      })
    end
  end
  local arrivingTrainSurface = arrivingTrainEntity.surface
  for _, trainCarriage in pairs(trainCarriages) do
    local driver = trainCarriage.get_driver()
    trainCarriage.destroy{raise_destroy = true}
    if driver then -- driver is ejected
      driver.teleport(Traincontroller:getTrainControllerRailPosition(arrivingTrain["trainDemolishingIndex"]))
    end
  end
  for _, trainCarriage in pairs(trainCarriagesToCreate) do
    local createdEntity = arrivingTrainSurface.create_entity(trainCarriage)
    local content = trainCarriage.content
    for fuelName, fuelAmount in pairs(content.fuel) do
      createdEntity.get_fuel_inventory().insert{name = fuelName, count = fuelAmount} --insert fuel
    end
    for itemName, itemAmount in pairs(content.item_cargo) do
      createdEntity.get_inventory(defines.inventory.cargo_wagon).insert{name = itemName, count = itemAmount}  --insert items
    end
    for fluidName, fluidAmount in pairs(content.fluid_cargo) do
      createdEntity.insert_fluid{name = fluidName, amount = fluidAmount}
    end
    for ammoName, ammoAmount in pairs(content.artillery_cargo) do
      createdEntity.get_inventory(defines.inventory.artillery_wagon_ammo).insert{name = ammoName, count = ammoAmount}
    end
  end
--  TODO: insert depleted fuel content into clone line 152
--  TODO: insert equipment into clone line 152

  return true
end



--------------------------------------------------------------------------------
-- Event interface
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:onTick(event)
  local pathingTrains = self:getPathingTrains()
  if LSlib.utils.table.isEmpty(pathingTrains) then return end
  local pathingTrainAmount = #pathingTrains
  local pathingTrainIndex = 1
  while pathingTrainIndex <= pathingTrainAmount do
    if self:monitorArrivingTrain(pathingTrains[pathingTrainIndex]) then
      -- train has arrived at destination
      local trainDemolishingIndex = self:getPathingTrains()[pathingTrainIndex]["trainDemolishingIndex"]
      self:removeArrivingTrain(pathingTrainIndex)
      pathingTrainAmount = pathingTrainAmount - 1
      if pathingTrainAmount == 0 then
        Traincontroller.Demolisher:deactivateOnTick()
      end
      Traincontroller.Demolisher:activateDemolisher(trainDemolishingIndex)
    else
      -- train has not arrived fully at destination
      pathingTrainIndex = pathingTrainIndex + 1
    end
  end

end



function Traincontroller.Demolisher.Conductor:onTrainScheduleChanged(trainEntity)
  local trainState = trainEntity.state
  if trainState == defines.train_state.arrive_station then
    -- STEP 1: check if the train is pathing to a disassembler controller
    local trainScheduledStop = trainEntity.path_end_stop -- train stop entity
    if trainScheduledStop then
      if trainScheduledStop.name ~= Traincontroller:getControllerEntityName() then return end
    else
      -- pathing to a rail, we have to check if it paths to a disassembler controller indirectly
      local trainScheduledRail = trainEntity.path_end_rail -- rail near train stop entity
      if not trainScheduledRail then return end -- invalid pathing??

      -- find the train stop that we are pathing to
      local trainRailDirection = trainScheduledRail.direction
      local trainRailPosition = trainScheduledRail.position
      if trainRailDirection == defines.direction.north or trainRailDirection == defines.direction.south then
        trainScheduledStop = trainScheduledRail.surface.find_entities_filtered{
          name  = Traincontroller:getControllerEntityName(),
          force = trainEntity.front_stock.force,
          area  = {{trainRailPosition.x - 2, trainRailPosition.y}, {trainRailPosition.x + 2, trainRailPosition.y}},
          limit = 1
        }[1]
      else -- east/west
        trainScheduledStop = trainScheduledRail.surface.find_entities_filtered{
          name  = Traincontroller:getControllerEntityName(),
          force = trainEntity.front_stock.force,
          area  = {{trainRailPosition.x, trainRailPosition.y - 2}, {trainRailPosition.x, trainRailPosition.y + 2}},
          limit = 1
        }[1]
      end

      if not trainScheduledStop then return end -- at least we tried finding a stop...
    end

    -- STEP 2: check if the disassembler has the same name as the train is pathing to
    local trainSchedule = trainEntity.schedule
    local trainScheduleStopName = trainSchedule.records[trainSchedule.current].station
    if not (trainScheduleStopName and trainScheduleStopName == trainScheduledStop.backer_name) then return end

    -- Now we must be pathing to a disassembler controller
    self:addArrivingTrain(trainEntity, trainScheduledStop)
    
  else
    -- TODO: delete train?
  end
end