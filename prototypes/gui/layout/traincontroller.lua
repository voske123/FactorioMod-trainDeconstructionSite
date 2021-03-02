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
----------------
return guiLayout