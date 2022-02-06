
-- default styles --------------------------------------------------------------
LSlib.styles.addTabStyle(LSlib.styles.getVanillaTabStyleSpecification())
local guiStyles = data.raw["gui-style"]["default"]

-- traincontroller custom styles ----------------------------------------------------
-- !!! NOTE !!!
-- The name 'traincontroller' cannot be used, as this is used in the trainConstructionSite.
-- As alternative, here we utlize the name 'trainController' instead.
guiStyles["trainController_contentFrame"] = util.table.deepcopy(guiStyles["traindepot_contentFrame"])
guiStyles["trainController_new_entry_flow"] = util.table.deepcopy(guiStyles["traindepot_new_entry_flow"])
guiStyles["trainController_new_entry_textfield"] = util.table.deepcopy(guiStyles["traindepot_new_entry_textfield"])
guiStyles["trainController_select_name_list_box"] = util.table.deepcopy(guiStyles["traindepot_select_name_list_box"])
guiStyles["trainController_statistics_table"] = util.table.deepcopy(guiStyles["traindepot_statistics_table"])
guiStyles["trainController_configuration_scrollpane"] = util.table.deepcopy(guiStyles["traincontroller_configuration_scrollpane"])
guiStyles["trainController_configuration_scrollpane"] = util.table.deepcopy(guiStyles["traincontroller_configuration_scrollpane"])
guiStyles["trainController_configuration_flow"] = util.table.deepcopy(guiStyles["traincontroller_configuration_flow"])

