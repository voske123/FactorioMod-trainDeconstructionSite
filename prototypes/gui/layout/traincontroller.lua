-- !!! NOTE !!!
-- The name 'traincontroller' cannot be used, as this is used in the trainConstructionSite.
-- As alternative, here we utlize the name 'trainController' instead.

local guiLayout = LSlib.gui.layout.create("screen")

local guiFlow = LSlib.gui.layout.addFrame(guiLayout, "root", "trainController-gui", "horizontal", {
  style = "traincontroller_contentFlowingFrame", -- no padding
})

local guiFrame = LSlib.gui.layout.addFrame(guiLayout, guiFlow, "trainController-mainframe", "vertical", {
  --caption = {"item-name.trainController", {[1] = "item-name.trainassembly"}},
  style   = "frame",
})

local guiFrameHeaderFlow = LSlib.gui.layout.addFlow(guiLayout, guiFrame, "trainController-mainframe-gui-header", "horizontal", {
  style = "LSlib_default_header",
})

LSlib.gui.layout.addLabel(guiLayout, guiFrameHeaderFlow, "trainController-mainframe-gui-header-title", {
  caption = {"item-name.traincontroller", {[1] = "item-name.traindisassembly"}},
  style   = "LSlib_default_frame_title",
  ignored_by_interaction = true,
})
LSlib.gui.layout.addEmptyWidget(guiLayout, guiFrameHeaderFlow, "trainController-mainframe-gui-header-filler", {
  drag_target = guiFlow,
  style       = "LSlib_default_draggable_header",
})
--LSlib.gui.layout.addSpriteButton(guiLayout, guiFrameHeaderFlow, "trainController-help", {
--  sprite = "utility/questionmark"      ,
--  style = "LSlib_default_header_button",
--})
LSlib.gui.layout.addSpriteButton(guiLayout, guiFrameHeaderFlow, "trainController-close", {
  sprite = "utility/close_white"      ,
  style = "LSlib_default_header_button",
})

local guiTabContent = LSlib.gui.layout.addTabs(guiLayout, guiFrame, "trainController-tab", {
  { -- first tab
    name     = "-statistics"                         ,
    caption  = {"gui-trainController.tab-statistics"},
    selected = true                                  ,
  },
  { -- second tab
    name     = "-selection"                              ,
    caption  = {"gui-trainController.tab-name-selection"},
    --selected = true                                      ,
  },
}, {
  buttonFlowStyle      = "LSlib_default_tab_buttonFlow"     ,
  buttonStyle          = "LSlib_default_tab_button"         ,
  buttonSelectedStyle  = "LSlib_default_tab_button_selected",
  tabInsideFrameStyle  = "LSlib_default_tab_insideDeepFrame",
  --tabContentFrameStyle = "LSlib_default_tab_contentFrame"   ,
  tabContentFrameStyle = "trainController_contentFrame"     ,
})



--------------------------------------------------------------------------------
-- Name selection tab                                                         --
--------------------------------------------------------------------------------
local guiTabContent2 = LSlib.gui.layout.getTabContentFrameFlow(guiLayout, guiTabContent, 2)

local guiNewEntryFlow = LSlib.gui.layout.addFlow(guiLayout, guiTabContent2, "new-entry", "horizontal", {
  style = "trainController_new_entry_flow",
})

LSlib.gui.layout.addLabel(guiLayout, guiNewEntryFlow, "selected-demolisher-label", {
  caption = {"", {"gui-trainController.new-name-field"}, " [img=info]"},
  tooltip = {"gui-trainController.new-name-field-tooltip"},
})
LSlib.gui.layout.addTextfield(guiLayout, guiNewEntryFlow, "selected-demolisher-name", {
  text    = "Enter demolisher name",
  tooltip = {"gui-trainController.new-name-field-tooltip"},
  style = "trainController_new_entry_textfield",
})
LSlib.gui.layout.addSpriteButton(guiLayout, guiNewEntryFlow, "selected-demolisher-enter", {
  sprite = "utility/enter",
  style = "tool_button"   ,
})

LSlib.gui.layout.addListbox(guiLayout, guiTabContent2, "selected-demolisher-list", {
  items = {"test1", "test2", "test3"},
  style = "trainController_select_name_list_box",
})



--------------------------------------------------------------------------------
-- statistics tab                                                             --
--------------------------------------------------------------------------------
local guiTabContent1 = LSlib.gui.layout.getTabContentFrameFlow(guiLayout, guiTabContent, 1)

local statistics = LSlib.gui.layout.addTable(guiLayout, guiTabContent1, "statistics", 2, {
  style = "trainController_statistics_table",
})

-- name
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-station-id", {
  caption = {"", {"gui-trainController.connected-demolisher-name"}, " [img=info]"},
  tooltip = {"gui-trainController.connected-demolisher-name-tooltip"},
})
local stationIDflow = LSlib.gui.layout.addFlow(guiLayout, statistics, "statistics-station-id-flow", "horizontal", {
  style = "centering_horizontal_flow",
})
LSlib.gui.layout.addLabel(guiLayout, stationIDflow, "statistics-station-id-value", {
  caption = {"gui-trainController.unused-demolisher-name"},
  ignored_by_interaction = true,
})
LSlib.gui.layout.addSpriteButton(guiLayout, stationIDflow, "statistics-station-id-edit", {
  sprite = "utility/rename_icon_small_black",
  style = "mini_button",
})

-- deconstructor size
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-demolisher-size", {
  caption = {"", {"gui-trainController.demolisher-availability"}, " [img=info]"},
  tooltip = {"gui-trainController.demolisher-availability-tooltip"},
})
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-decontroller-size-value", {
  caption = "-999/999",
  ignored_by_interaction = true,
})

-- controller status
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-demolisher-status", {
  caption = {"gui-trainController.demolisher-status"},
  ignored_by_interaction = true,
})
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-demolisher-status-value", {
  caption = "undefined status",
  ignored_by_interaction = true,
})

-- controller configuration
LSlib.gui.layout.addLabel(guiLayout, statistics, "statistics-demolisher-configuration", {
  caption = {"gui-trainController.demolisher-configuration"},
  ignored_by_interaction = true,
})
local controllerFlow = LSlib.gui.layout.addScrollPane(guiLayout, guiTabContent1, "statistics-demolisher-configuration-flow-scrolling", {
  horizontal_scroll_policy = "always",
  vertical_scroll_policy   = "never" ,

  style = "trainController_configuration_scrollpane",
})
controllerFlow = LSlib.gui.layout.addFlow(guiLayout, controllerFlow, "statistics-demolisher-configuration-flow", "horizontal", {
  style = "research_queue_first_slot_flow", -- no padding
})



----------------
return guiLayout