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
  for _,tabButtonName in pairs{
    "trainController-tab-selection" ,
    "trainController-tab-statistics",
  } do
    tabButtonPath[tabButtonName] = LSlib.gui.layout.getElementPath(trainControllerGui, tabButtonName)
  end

  -- updateElementPath
  local updateElementPath = {}
  for _,selectionTabElementName in pairs{
    "selected-demolisher-name", -- current/new depot name
    "selected-demolisher-list", -- list of all depot names
  } do
    updateElementPath[selectionTabElementName] = LSlib.gui.layout.getElementPath(trainControllerGui, selectionTabElementName)
  end
  for _,statisticsTabElementName in pairs{
    "statistics-station-id-value"                , -- controller name
    "statistics-demolisher-size-value"             , -- depot request amount
    "statistics-demolisher-status-value"            , -- controller status
    "statistics-demolisher-configuration-flow"      , -- controller configuration

    --"traincontroller-color-picker"               , -- color picking frame
    --"traincontroller-color-picker-entity-preview", -- color picker entity preview
  } do
    updateElementPath[statisticsTabElementName] = LSlib.gui.layout.getElementPath(trainControllerGui, statisticsTabElementName)
  end

  return {
    -- gui layout
    ["trainControllerGui"] = trainControllerGui,

    -- gui element paths (derived from layout)
    ["tabButtonPath"     ] = tabButtonPath     ,
    ["updateElementPath" ] = updateElementPath ,

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



  ------------------------------------------------------------------------------
  -- tab button handler
  ------------------------------------------------------------------------------
  local tabButtonHandler = function(clickedTabButton, playerIndex)

    -- Get the flow with all the buttons
    if clickedTabButton.type ~= "button" then return end -- clicked on content
    local tabButtonFlow = clickedTabButton.parent

    -- Get the flow with all the contents
    local tabContentFlow = tabButtonFlow.parent
    tabContentFlow = tabContentFlow[tabContentFlow.name .. "-content"]
    if not tabContentFlow then return end

    -- For each button in the flow, set the new style and set the tabs
    local clickedTabButtonName = clickedTabButton.name
    for _,tabButtonName in pairs{
      "trainController-tab-selection" ,
      "trainController-tab-statistics",
    } do
      tabButtonFlow[tabButtonName].style = (tabButtonName == clickedTabButtonName and "LSlib_default_tab_button_selected" or "LSlib_default_tab_button")
      tabContentFlow[tabButtonName].visible = (tabButtonName == clickedTabButtonName)
    end
  end

  for _,tabButtonName in pairs{
    "trainController-tab-selection" ,
    "trainController-tab-statistics",
  } do
    clickHandlers[tabButtonName] = tabButtonHandler
  end



  ------------------------------------------------------------------------------
  -- statistics
  ------------------------------------------------------------------------------
  clickHandlers["statistics-station-id-edit"] = function(clickedElement, playerIndex)
    local tabToOpen = "trainController-tab-selection"
    Traincontroller.Gui:getClickHandler(tabToOpen)(LSlib.gui.getElement(playerIndex, Traincontroller.Gui:getTabElementPath(tabToOpen)), playerIndex) -- mimic tab pressed
  end



  --[[clickHandlers["statistics-builder-configuration-button-recipe"] = function(clickedElement, playerIndex)
    local player = game.get_player(playerIndex)
    local recipeEntity =  player.surface.create_entity{
      name     = Traincontroller.Gui:getRecipeSelectorEntityName(),
      position = player.position,
      force    = player.force,
    }
    Traincontroller.Gui:setOpenedRecipeEntity(playerIndex, recipeEntity)
    player.opened = recipeEntity
  end]]


  
  ------------------------------------------------------------------------------
  -- select train deconstructor name
  ------------------------------------------------------------------------------
  clickHandlers["selected-demolisher-list"] = function(clickedElement, playerIndex)
    local listboxElement = LSlib.gui.getElement(playerIndex, Traincontroller.Gui:getUpdateElementPath("selected-demolisher-list"))

    LSlib.gui.getElement(playerIndex, Traincontroller.Gui:getUpdateElementPath("selected-demolisher-name")).text = listboxElement.get_item(listboxElement.selected_index)
  end



  clickHandlers["selected-demolisher-enter"] = function(clickedElement, playerIndex)
    local controllerEntity  = Traincontroller.Gui:getOpenedControllerEntity(playerIndex)
    local oldControllerName = controllerEntity.backer_name
    local newControllerName = LSlib.gui.getElement(playerIndex, Traincontroller.Gui:getUpdateElementPath("selected-demolisher-name")).text

    if newControllerName ~= oldControllerName then
      controllerEntity.backer_name = newControllerName -- invokes the rename event which will update UI's
      Traincontroller.Gui:updateGuiInfo(playerIndex)   -- update twice to refresh the list
    end

    -- mimic tab pressed to go back to statistics tab
    local tabToOpen = "trainController-tab-statistics"
    Traincontroller.Gui:getClickHandler(tabToOpen)(LSlib.gui.getElement(playerIndex, Traincontroller.Gui:getTabElementPath(tabToOpen)), playerIndex)
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



function Traincontroller.Gui:getTabElementPath(guiElementName)
  return global.TC_data.Gui["prototypeData"]["tabButtonPath"][guiElementName]
end



function Traincontroller.Gui:getUpdateElementPath(guiElementName)
  return global.TC_data.Gui["prototypeData"]["updateElementPath"][guiElementName]
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
    self:onCloseEntity(trainControllerGui, playerIndex)
  end

  game.print("TODO: Traincontroller.Gui:updateGuiInfo")
  local controllerName            = openedEntity.backer_name or ""
  local controllerSurfaceIndex    = openedEntity.surface.index or 1
  local controllerIndex           = Traincontroller:getTrainDemolisherIndex(openedEntity)
  local controllerDirection       = openedEntity.direction or defines.direction.north

  local trainDemolisher           = TrainDisassembly:getTrainDemolisher(controllerIndex)
  local demolishingCapacityCount  = #trainDemolisher
  local demolishingTrainCount     = 0
  for _, demolisherPosition in pairs(trainDemolisher) do
    local removedEntity = TrainDisassembly:getRemovedEntity(demolisherPosition.surfaceIndex, demolisherPosition.position)
    if removedEntity then
      demolishingTrainCount = demolishingTrainCount + 1
    end
  end
  local trainDemolisherIterator = TrainDisassembly:getTrainDemolisherIterator(controllerDirection)

  -- statistics ----------------------------------------------------------------
  -- controller deconstructor name
  LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("statistics-station-id-value")).caption = controllerName

  -- demolishing amount of trains in deconstructor
  LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("statistics-demolisher-size-value")).caption = string.format(
    "%i/%i", demolishingTrainCount, demolishingCapacityCount)

  -- status of the builder
  --LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("statistics-demolisher-status-value")).caption = self:getOpenedControllerStatusString(playerIndex)
  game.print("traincontroller-gui lijn 339 TODO")

  -- configuration
  local configurationElement = LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("statistics-demolisher-configuration-flow"))
  configurationElement.clear()
  configurationElement.add{
    type      = "flow",
    name      = "0-traincontroller",
    direction = "vertical",
    style     = "trainController_configuration_flow",
  }.add{
    type    = "sprite-button",
    name    = "statistics-builder-configuration-button-recipe",
    tooltip = {"item-name.traincontroller", {"item-name.traindisassembly"}},
    sprite  = string.format("item/%s", Traincontroller:getControllerItemName()),
    enabled = false,
  }
  for trainDisassemblerIndex,trainDisassemblerLocation in trainDemolisherIterator(trainDemolisher) do
    local trainDisassembler = TrainDisassembly:getMachineEntity(trainDisassemblerLocation.surfaceIndex, trainDisassemblerLocation.position)
    if trainDisassembler and trainDisassembler.valid then
      local flow = configurationElement.add{
        type      = "flow",
        name      = string.format("%i", trainDisassemblerIndex),
        direction = "vertical",
        style     = "trainController_configuration_flow",
      }

      local trainDisassemblerRecipe = trainDisassembler.get_recipe()
      if trainDisassemblerRecipe then
        flow.add{
          type   = "sprite-button",
          name   = "statistics-demolisher-configuration-button-recipe",
          sprite = string.format("fluid/%s", trainDisassemblerRecipe.ingredients[1].name),
          enabled = false,
        }

        --[[local trainAssemblyType = LSlib.utils.string.split(trainAssemblerRecipe.name, "[")[2]
        trainAssemblyType = trainAssemblyType:sub(1, trainAssemblyType:len()-1)
        if trainAssemblyType == "locomotive"      or
           trainAssemblyType == "artillery-wagon" then
          flow.add{
            type    = "sprite-button",
            name    = "statistics-builder-configuration-button-rotate",
            tooltip = {"controls.rotate"},
            sprite  = string.format("traincontroller-orientation-%s", trainAssembler.direction == controllerDirection and "L" or "R"),
          }

          if trainAssemblyType == "locomotive" then
            flow.add{
              type    = "button",
              name    = "statistics-builder-configuration-button-color",
              tooltip = {"gui-train.color"},
              style   = "traincontroller_color_indicator_button_housing",
            }.add{
              type  = "progressbar",
              name  = "statistics-builder-configuration-button-color",
              value = 1,
              style = "traincontroller_color_indicator_button_color",
              ignored_by_interaction = true,
            }.add{
              type   = "sprite-button",
              name   = "statistics-builder-configuration-button-color",
              sprite = "utility/color_picker",
              style  = "traincontroller_color_indicator_button_sprite",
              ignored_by_interaction = true,
            }.parent.style.color = Trainassembly:getMachineTint(trainAssembler)
          end
        end--]]
      else 
        flow.add{
          type   = "sprite-button",
          name   = "statistics-demolisher-configuration-button-recipe",
          sprite = string.format("entity/%s", TrainDisassembly:getMachineEntityName()),
          enabled = false,
        }
      end

    end
  end

  -- select depot name ---------------------------------------------------------
  LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("selected-demolisher-name")).caption = controllerName

  -- name selection list
  local deconstructorEntriesList = LSlib.gui.getElement(playerIndex, self:getUpdateElementPath("selected-demolisher-list"))
  deconstructorEntriesList.clear_items()
  
  local itemIndex = 1
  local orderedPairs = LSlib.utils.table.orderedPairs
  for trainControllerName,_ in orderedPairs(Traincontroller:getAllTrainControllerNames(controllerSurfaceIndex)) do
    -- https://lua-api.factorio.com/latest/LuaGuiElement.html#LuaGuiElement.add_item
    deconstructorEntriesList.add_item(trainControllerName)
    if trainControllerName == controllerName then
      deconstructorEntriesList.selected_index = itemIndex
    end
    itemIndex = itemIndex + 1
  end
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
