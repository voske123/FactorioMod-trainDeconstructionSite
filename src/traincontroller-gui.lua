require 'util'
require("__LSlib__/LSlib")

-- Create class
Traincontroller.Gui = {}

--------------------------------------------------------------------------------
-- Initiation of the class
--------------------------------------------------------------------------------
function Traincontroller.Gui:onInit()
  if not global.TC_data.Gui then
    global.TC_data.Gui = self:initGlobalData()
  end
end



-- Initiation of the global data
function Traincontroller.Gui:initGlobalData()
  local gui = {
    ["version"       ] = 1, -- version of the global data
    ["prototypeData" ] = self:initPrototypeData(), -- data storing info about the prototypes
    ["openedEntities"] = {}, -- opened entity for each player
  }

  return util.table.deepcopy(gui)
end



local trainControllerGui = require "prototypes.gui.layout.traincontroller"
function Traincontroller.Gui:initPrototypeData()
  -- tabButtonPath
  local tabButtonPath = {}
  --[[for _,tabButtonName in pairs{
    "traincontroller-tab-selection" ,
    "traincontroller-tab-statistics",
  } do
    tabButtonPath[tabButtonName] = LSlib.gui.layout.getElementPath(trainControllerGui, tabButtonName)
  end--]]

  -- updateElementPath
  local updateElementPath = {}
  --[[for _,selectionTabElementName in pairs{
    "selected-depot-name", -- current/new depot name
    "selected-depot-list", -- list of all depot names
  } do
    updateElementPath[selectionTabElementName] = LSlib.gui.layout.getElementPath(trainControllerGui, selectionTabElementName)
  end
  for _,statisticsTabElementName in pairs{
    "statistics-station-id-value"                , -- controller name
    "statistics-depot-request-value"             , -- depot request amount
    "statistics-builder-status-value"            , -- controller status
    "statistics-builder-configuration-flow"      , -- controller configuration

    "traincontroller-color-picker"               , -- color picking frame
    "traincontroller-color-picker-entity-preview", -- color picker entity preview
  } do
    updateElementPath[statisticsTabElementName] = LSlib.gui.layout.getElementPath(trainControllerGui, statisticsTabElementName)
  end--]]

  return {
    -- gui layout
    ["trainControllerGui"] = trainControllerGui,

    -- gui element paths (derived from layout)
    --["tabButtonPath"     ] = tabButtonPath     ,
    --["updateElementPath" ] = updateElementPath ,

    --["recipeSelector"    ] = Trainassembly:getMachineEntityName() .. "-recipe-selector"
  }
end



function Traincontroller.Gui:initClickHandlers()
  local clickHandlers = {}

  ------------------------------------------------------------------------------
  -- help button handler
  ------------------------------------------------------------------------------
  --[[
  clickHandlers["trainController-help"] = function(clickedElement, playerIndex)
    -- close this UI
    game.players[playerIndex].opened = Traincontroller.Gui:destroyGui(playerIndex)
    Traincontroller.Gui:setOpenedControllerEntity(playerIndex, nil)

    -- open the new UI
    --Help.Gui:openGui(playerIndex)
  end
  --]]



  ------------------------------------------------------------------------------
  -- close button handler
  ------------------------------------------------------------------------------
  clickHandlers["trainController-close"] = function(clickedElement, playerIndex)
    -- close this UI
    game.players[playerIndex].opened = Traincontroller.Gui:destroyGui(playerIndex)
    Traincontroller.Gui:setOpenedControllerEntity(playerIndex, nil)
  end



  --------------------
  return clickHandlers
end
Traincontroller.Gui.clickHandlers = Traincontroller.Gui:initClickHandlers()


--------------------------------------------------------------------------------
-- Setter functions to alter data into the data structure
--------------------------------------------------------------------------------
function Traincontroller.Gui:setOpenedControllerEntity(playerIndex, openedEntity)
  if not global.TC_data.Gui["openedEntities"][playerIndex] then
    global.TC_data.Gui["openedEntities"][playerIndex] = {}
  end
  global.TC_data.Gui["openedEntities"][playerIndex]["traincontroller"] = openedEntity
end



--------------------------------------------------------------------------------
-- Getter functions to extract data from the data structure
--------------------------------------------------------------------------------
function Traincontroller.Gui:getControllerGuiLayout()
  return global.TC_data.Gui["prototypeData"]["trainControllerGui"]
end



function Traincontroller.Gui:getClickHandler(guiElementName)
  return Traincontroller.Gui.clickHandlers[guiElementName]
end



function Traincontroller.Gui:getGuiName()
  return LSlib.gui.getRootElementName(self:getControllerGuiLayout())
end



function Traincontroller.Gui:getOpenedControllerStatusString(playerIndex)
  --[[
  local controllerStatus = Traincontroller.Builder:getControllerStatus(self:getOpenedControllerEntity(playerIndex))
  local controllerStates  = global.TC_data.Builder["builderStates"]

  if controllerStatus == controllerStates["idle"] then
    -- wait until a depot request a train
    return {"gui-traincontroller.controller-status-wait-to-dispatch"}

  elseif controllerStatus == controllerStates["building"] then
    -- waiting on resources, building each component
    return {"gui-traincontroller.controller-status-building-train"}

  elseif controllerStatus == controllerStates["dispatching"] then
    -- waiting till previous train clears the train block
    return {"gui-traincontroller.controller-status-ready-to-dispatch"}

  elseif controllerStatus == controllerStates["dispatch"] then
    -- assembling the train components together and let the train drive off
    return {"gui-traincontroller.controller-status-ready-to-dispatch"}

  else return "undefined status" end
  --]]
  return "TODO: Traincontroller.Gui:getOpenedControllerStatusString"
end



function Traincontroller.Gui:getOpenedControllerEntity(playerIndex)
  if global.TC_data.Gui["openedEntities"][playerIndex] then
    return global.TC_data.Gui["openedEntities"][playerIndex]["traincontroller"]
  else
    return nil
  end
end



function Traincontroller.Gui:hasOpenedGui(playerIndex)
  return self:getOpenedControllerEntity(playerIndex) and true or false
end



--------------------------------------------------------------------------------
-- Gui functions
--------------------------------------------------------------------------------
function Traincontroller.Gui:createGui(playerIndex)
  local trainDepoGui = LSlib.gui.create(playerIndex, self:getControllerGuiLayout())
  self:updateGuiInfo(playerIndex)
  return trainDepoGui
end



function Traincontroller.Gui:destroyGui(playerIndex)
  return LSlib.gui.destroy(playerIndex, self:getControllerGuiLayout())
end



function Traincontroller.Gui:updateGuiInfo(playerIndex)
  -- We expect the gui to be created already
  local trainControllerGui = LSlib.gui.getElement(playerIndex, LSlib.gui.layout.getElementPath(self:getControllerGuiLayout(), self:getGuiName()))
  if not trainControllerGui then return end -- gui was not created, nothing to update

  -- data from the traindepo we require to update
  local openedEntity           = self:getOpenedControllerEntity(playerIndex)
  if not (openedEntity and openedEntity.valid) then
    self:onCloseEntity(trainDepotGui, playerIndex)
  end

  game.print("TODO: Traincontroller.Gui:updateGuiInfo")
end



function Traincontroller.Gui:updateOpenedGuis(updatedControllerEntity)

  for _,player in pairs(game.connected_players) do -- no need to check all players
    local openedEntity = self:getOpenedControllerEntity(player.index)
    if openedEntity then
      if openedEntity.valid and openedEntity.health > 0 then
        if openedEntity == updatedControllerEntity then
          self:updateGuiInfo(player.index)
        end
      else -- not valid/killed
        self:onCloseEntity(player.opened, player.index)
      end
    end
  end

end



--------------------------------------------------------------------------------
-- Behaviour functions, mostly event handlers
--------------------------------------------------------------------------------
-- When a player opens a gui
function Traincontroller.Gui:onOpenEntity(openedEntity, playerIndex)
  if openedEntity and openedEntity.name == Traincontroller:getControllerEntityName() then
    self:setOpenedControllerEntity(playerIndex, openedEntity)
    game.players[playerIndex].opened = self:createGui(playerIndex)
  end
end



-- When a player opens/closes a gui
function Traincontroller.Gui:onCloseEntity(openedGui, playerIndex)
  if openedGui and openedGui.valid then
    if openedGui.name == self:getGuiName() then
      game.players[playerIndex].opened = self:destroyGui(playerIndex)
      self:setOpenedControllerEntity(playerIndex, nil)
    end
  end
end



-- When a player clicks on the gui
function Traincontroller.Gui:onClickElement(clickedElement, playerIndex)
  if self:hasOpenedGui(playerIndex) then
    if not clickedElement.valid then return end
    local clickHandler = self:getClickHandler(clickedElement.name)
    if clickHandler then clickHandler(clickedElement, playerIndex) end
  end
end



function Traincontroller.Gui:onPlayerLeftGame(playerIndex)
  -- Called after a player leaves the game.
  if self:hasOpenedGui(playerIndex) then
    self:onCloseEntity(game.players[playerIndex].opened, playerIndex)
  end
end
