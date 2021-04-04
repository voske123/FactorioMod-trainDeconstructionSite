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
    --selected = true                                  ,
  },
  { -- second tab
    name     = "-selection"                              ,
    caption  = {"gui-trainController.tab-name-selection"},
    selected = true                                      ,
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

LSlib.gui.layout.addLabel(guiLayout, guiNewEntryFlow, "selected-deconstructor-label", {
  caption = {"", {"gui-trainController.new-name-field"}, " [img=info]"},
  tooltip = {"gui-trainController.new-name-field-tooltip"},
})
LSlib.gui.layout.addTextfield(guiLayout, guiNewEntryFlow, "selected-deconstructor-name", {
  text    = "Enter demolisher name",
  tooltip = {"gui-trainController.new-name-field-tooltip"},
  style = "trainController_new_entry_textfield",
})
LSlib.gui.layout.addSpriteButton(guiLayout, guiNewEntryFlow, "selected-deconstructor-enter", {
  sprite = "utility/enter",
  style = "tool_button"   ,
})

LSlib.gui.layout.addListbox(guiLayout, guiTabContent2, "selected-deconstructor-list", {
  items = {"test1", "test2", "test3"},
  style = "trainController_select_name_list_box",
})



--------------------------------------------------------------------------------
-- statistics tab                                                             --
--------------------------------------------------------------------------------
local guiTabContent1 = LSlib.gui.layout.getTabContentFrameFlow(guiLayout, guiTabContent, 1)
--TODO

----------------
return guiLayout