require 'util'
require("__LSlib__/LSlib")

-- Create class
Traincontroller.Demolisher = {}
require 'src.traincontroller-conductor'

--------------------------------------------------------------------------------
-- Initiation of the class
--------------------------------------------------------------------------------
function Traincontroller.Demolisher:onInit()
  if not global.TC_data.Demolisher then
    global.TC_data.Demolisher = self:initGlobalData()
  end
  self.Conductor:onInit()
end



function Traincontroller.Demolisher:onLoad()
  -- sync the on tick event
  if global.TC_data.Demolisher["onTickActive"] then
    self:activateOnTick()
  else
    self:deactivateOnTick()
  end
end



-- called when a mod setting changed
function Traincontroller.Demolisher:onSettingChanged(event)
  -- check if the tickrate has changed
  if event.setting_type == "runtime-global" and event.setting == "trainController-tickRate" then
    -- we need to update the on_nth_tick event (step 2), but we fist need to
    -- disable the old one if it was active (step 1), and if it was active,
    -- we have to reactivate it afther updating the settings (step 3)
    local onTickWasActive = global.TC_data.Demolisher["onTickActive"]

    -- STEP 1: disable the old active on_tick
    if onTickWasActive then
      self:deactivateOnTick()
    end

    -- STEP 2: update the settings
    global.TC_data.Demolisher["onTickDelay"] = settings.global[event.setting].value

    -- STEP 3: reactivate the on_tick with new settings
    if onTickWasActive then
      self:activateOnTick()
    end

  end
end



-- Initiation of the global data
function Traincontroller.Demolisher:initGlobalData()
  local Demolisher = {
    ["version"] = 1, -- version of the global data
    ["onTickActive"] = false, -- if the on_tick event is active or not
    ["onTickDelay"] = settings.global["trainController-tickRate"].value,

    ["demolisherStates"] = { -- states in the builder process
      ["initialState"] = 1, -- what state the controller is in when it is placed down

      ["idle"        ] = 1, -- wait until a train is requested to be demolished
      ["emptying"    ] = 2, -- remove any cargo/fuel from the train
      ["priming"     ] = 3, -- initialising the deconstruction process
      ["demolishing" ] = 4, -- disassembling each carrier seperately
    },
  }

  return util.table.deepcopy(Demolisher)
end



--------------------------------------------------------------------------------
-- Setter functions to alter data into the data structure
--------------------------------------------------------------------------------
function Traincontroller.Demolisher:activateDemolisher(trainDemolisherIndex)
  -- STEP 1: find a suitable train that can be demolished
  local trainToBeDemolished = nil
  local trainDemolishers = TrainDisassembly:getTrainDemolisher(trainDemolisherIndex)
  local trainDemolisherSurfaceIndex = trainDemolishers[1]["surfaceIndex"]
  local trainDemolisherSurface = game.get_surface(trainDemolisherSurfaceIndex)
  for _,trainDemolisher in pairs(trainDemolishers or {}) do
    trainToBeDemolished = trainDemolisherSurface.find_entities_filtered{
      type     = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"},
      position = trainDemolisher["position"],
      limit    = 1
    }[1]
    if trainToBeDemolished then break end
  end
  if not trainToBeDemolished then return end -- did not find a train to be demolished... not activating
  
  local trainCarriages = trainToBeDemolished.train.carriages
  if #trainCarriages > #trainDemolishers then return end -- demolisher is not large enough... not activating

  -- STEP 2: register the demolisher to the disassemblers
  local succeeded = true
  for _, trainCarriage in pairs(trainCarriages) do
    if not TrainDisassembly:setRemovedEntity(trainDemolisherSurfaceIndex, trainCarriage.position, trainCarriage) then
      succeeded = false
      break
    end
  end
  if not succeeded then
    for _, trainDemolisher in pairs(trainDemolishers) do
      TrainDisassembly:setRemovedEntity(trainDemolisher["surfaceIndex"], trainDemolisher["position"], nil)
    end
    return -- failed to find a disassembler for a carriage... not activating
  end

  -- STEP 3: enable demolisher
  local trainController = Traincontroller:getTrainController(trainDemolisherIndex)
  global.TC_data["trainControllers"][trainController.surface.index][trainController.position.y][trainController.position.x]["controllerStatus"] = global.TC_data.Demolisher["demolisherStates"]["emptying"]
  log(serpent.block(global.TC_data.Demolisher))
end



function Traincontroller.Demolisher:cancelDemolishionOfTrain(trainDemolisherIndex)
  -- delete the whole created train from a builder
  for _, demolisherLocation in pairs(TrainDisassembly:getTrainDemolisher(trainDemolisherIndex)) do
    TrainDisassembly:cancelDemolishionOfEntity(demolisherLocation["surfaceIndex"], demolisherLocation["position"])
  end
end



--------------------------------------------------------------------------------
-- Getter functions to extract data from the data structure
--------------------------------------------------------------------------------
function Traincontroller.Demolisher:getDemolishingCarriages(trainDemolisherIndex)
  -- this function returns the carriages of the train to be demolished train, or an empty table if none found
  local trainDemolisherCarriages = {}
  log("TODO: Traincontroller.Demolisher:getDemolishingCarriages")
--  local trainDemolisher = TrainDisassembly:getTrainDemolisher(trainDemolisherIndex)
--  if not trainDemolisher then return nil end
--
--  -- STEP 1: Connect all the wagons together
--  --         The whole train is already connected, so no need to do this manual
--
--  -- STEP 2: Find one entity that is part of this train
--  local machineLocation = trainDemolisher[1] -- we know this one is always used (train with length 1)
--  if not machineLocation then return nil end
--
--  local trainEntity = Trainassembly:getCreatedEntity(machineLocation.surfaceIndex, machineLocation.position)
--  if not (trainEntity and trainEntity.valid) then return nil end
--
--  -- STEP 3: Find the train this trainEntity is part of
--  local train = trainEntity.train
--  if not (train and train.valid) then return nil end
--
--  -- STEP 4: Before returning this train, make sure this is the whole train! (becose of step 1)
--  if not (#train.carriages == #trainDemolisher) then
--    game.print("ERROR: The build train is not the fully build train, please report this to the mod author!")
--    return nil
--  end
--
--  -- STEP 5: Now we can return this train
--  return train
end



function Traincontroller.Demolisher:getControllerStatus(trainController)
  local position         = trainController.position
  return global.TC_data["trainControllers"][trainController.surface.index][position.y][position.x]["controllerStatus"]
end



function Traincontroller.Demolisher:hasControllers()
  return global.TC_data["nextTrainControllerIterate"] ~= nil
end



--------------------------------------------------------------------------------
-- Behaviour functions
--------------------------------------------------------------------------------
function Traincontroller.Demolisher:updateController(surfaceIndex, position)
  -- This function will check the update for a single controller
  --game.print("Updating controller @ ["..surfaceIndex..", "..position.x..", "..position.y.."]")
  local controllerData       = global.TC_data["trainControllers"][surfaceIndex][position.y][position.x]
  local controllerStates     = global.TC_data.Demolisher["demolisherStates"]
  local controllerStatus     = controllerData["controllerStatus"]
  local oldControllerStatus  = controllerStatus
  local controllerEntity     = controllerData["entity"]
  local trainDemolisherIndex = controllerData["trainDemolisherIndex"]


  if controllerStatus == controllerStates["idle"] then
    -- controller is waiting on a train to arrive
    -- controller is activated in Traincontroller.Demolisher:activateDemolisher(trainDemolisherIndex)
    --controllerStatus = controllerStates["emptying"]
  end


  if controllerStatus == controllerStates["emptying"] then
    -- remove any items/fuel from the train
    -- remove trainshedule
    game.print("TODO Traincontroller.Demolisher line 207")
    controllerStatus = controllerStates["priming"]
  end


  if controllerStatus == controllerStates["priming"] then
    -- registering the train to be demolised, put the recipe input into the furnaces if it is researched
    local trainDemolishers = TrainDisassembly:getTrainDemolisher(trainDemolisherIndex)

    for _, trainDemolisher in pairs(trainDemolishers) do
      local removedEntity = TrainDisassembly:getRemovedEntity(trainDemolisher.surfaceIndex, trainDemolisher.position)
      local furnaceEntity = TrainDisassembly:getMachineEntity(trainDemolisher.surfaceIndex, trainDemolisher.position)
      if removedEntity and removedEntity.valid and furnaceEntity and furnaceEntity.valid then
        furnaceEntity.insert_fluid({name = removedEntity.name .. "-fluid", amount = 1})
      end
    end

    controllerStatus = controllerStates["demolishing"]
  end


  if controllerStatus == controllerStates["demolishing"] then
    -- check schedule = empty
    -- wait on the furnaces to have processed the recipe
    -- remove train when done
    local trainDemolishers = TrainDisassembly:getTrainDemolisher(trainDemolisherIndex)
    for _, trainDemolisher in pairs(trainDemolishers) do
      local furnaceEntity = TrainDisassembly:getMachineEntity(trainDemolisher.surfaceIndex, trainDemolisher.position)
      if furnaceEntity and furnaceEntity.valid then 
        --TODO: check if recipe is finished
        --game.print(furnaceEntity.is_crafting())
      end
    end
    game.print("TODO Traincontroller.Demolisher line 240")
    --controllerStatus = controllerStates["idle"]
  end


  -- the controller could have been removed
  if global.TC_data["trainControllers"] and
     global.TC_data["trainControllers"][surfaceIndex] and
     global.TC_data["trainControllers"][surfaceIndex][position.y] and
     global.TC_data["trainControllers"][surfaceIndex][position.y][position.x] then

    -- save changes to the global data before any gui updates
    global.TC_data["trainControllers"][surfaceIndex][position.y][position.x]["controllerStatus"] = controllerStatus

    -- update the gui if needed
    if controllerStatus ~= oldControllerStatus then
      game.print("TODO Traincontroller.Demolisher line 277")
      --Traincontroller.Gui:updateOpenedGuis(controllerEntity)
    end
  end

end



--------------------------------------------------------------------------------
-- Event interface
--------------------------------------------------------------------------------
function Traincontroller.Demolisher:onTick(event)
  --game.print(game.tick)

  -- Update the conductor to check if new trains arrive at any train demolisher
  self.Conductor:onTick(event)

  -- Extract the controller that needs to be updated
  local controller   = util.table.deepcopy(global.TC_data["nextTrainControllerIterate"])
  if controller then
    local surfaceIndex = controller.surfaceIndex
    local position     = controller.position

    -- extract the next controller
    local nextController = util.table.deepcopy(
      global.TC_data["trainControllers"][controller.surfaceIndex][controller.position.y][controller.position.x]["nextController"]
    )

    -- Update the controller
    self:updateController(surfaceIndex, position)

    -- Increment the nextController
    if LSlib.utils.table.areEqual(controller, global.TC_data["nextTrainControllerIterate"]) then
      global.TC_data["nextTrainControllerIterate"] = nextController
    end
  end
end



function Traincontroller.Demolisher:activateOnTick()
  if game then game.print("on_tick activated") end
  script.on_nth_tick(global.TC_data.Demolisher["onTickDelay"], function(event)
    self:onTick(event)
  end)
  global.TC_data.Demolisher["onTickActive"] = true
end



function Traincontroller.Demolisher:deactivateOnTick()
  if game then game.print("on_tick deactivation request") end
  -- cannot deactivate if there are controllers to iterate over
  if self:hasControllers() then return end

  -- cannot deactivate if there are still trains pathing to the demolisher
  if self.Conductor:hasPathingTrains() then return end

  if game then game.print("on_tick deactivated") end
  script.on_nth_tick(global.TC_data.Demolisher["onTickDelay"], nil)
  global.TC_data.Demolisher["onTickActive"] = false
end

