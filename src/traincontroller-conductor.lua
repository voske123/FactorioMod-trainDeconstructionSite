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



--------------------------------------------------------------------------------
-- Getter functions to extract data from the data structure
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:getPathingTrains()
  return global.TC_data.Demolisher.Conductor["pathingTrains"]
end



--------------------------------------------------------------------------------
-- Behaviour functions
--------------------------------------------------------------------------------
function Traincontroller.Demolisher.Conductor:calculateArrivingSpeed(squaredDistance, initialSquaredDistance, initialSpeed)
  --return ( 1 - math.cos(squaredDistance/initialSquaredDistance*math.pi/2) ) * initialSpeed
  local speed = squaredDistance/initialSquaredDistance * initialSpeed
  if speed > 0.01 then
    return speed
  else
    return 0.01
  end
end



function Traincontroller.Demolisher.Conductor:monitorArrivingTrain(arrivingTrain)
  -- Returns true if train is arrived at destination
  local arrivingTrainEntity = arrivingTrain.trainEntity
  local arrivingTrainPosition = arrivingTrainEntity.position
  local demolisherPosition = arrivingTrain.trainDemolishingPosition
  local distanceX = demolisherPosition.x - arrivingTrainPosition.x
  local distanceY = demolisherPosition.y - arrivingTrainPosition.y
  local distanceSquared = distanceX * distanceX + distanceY * distanceY

  if distanceSquared > arrivingTrain["currentArrivingDistanceSquared"] then
    -- todo: we went too far....
    arrivingTrainEntity.train.speed = 0
    return false -- todo: return true
  end

  -- getting closer to destination
  arrivingTrainEntity.train.speed = Traincontroller.Demolisher.Conductor:calculateArrivingSpeed(
    distanceSquared, arrivingTrain["initialArrivingDistanceSquared"], arrivingTrain["initialArrivingSpeed"])
  log(arrivingTrainEntity.train.speed)
  arrivingTrain["currentArrivingDistanceSquared"] = distanceSquared
  return false
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
    if Traincontroller.Demolisher.Conductor:monitorArrivingTrain(pathingTrains[pathingTrainIndex]) then
      -- TODO: remove from pathing trains
      pathingTrainAmount = pathingTrainAmount - 1
    else
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
          name = Traincontroller:getControllerEntityName(),
          force = trainEntity.force,
          area = {{trainRailPosition.x - 2, trainRailPosition.y}, {trainRailPosition.x + 2, trainRailPosition.y}},
          limit = 1
        }[1]
      else -- east/west
        trainScheduledStop = trainScheduledRail.surface.find_entities_filtered{
          name = Traincontroller:getControllerEntityName(),
          force = trainEntity.force,
          area = {{trainRailPosition.x, trainRailPosition.y - 2}, {trainRailPosition.x, trainRailPosition.y + 2}},
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