EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
EggrollMelonAPI.ConfigGUI.ConfigTable = EggrollMelonAPI.ConfigGUI.ConfigTable or {}

--[[
Registers a config GUI
Arguments:
addonName - Name of the addon to display in the config
configID - string identifier to create config options
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable = {} --table with registered tables and options (to be received and sent to server)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = { --table with categories and options (for client)
		["General Config"] = {}
	}
end

function EggrollMelonAPI.ConfigGUI.RegisterTable()
end

--[[
Adds a category to the config
Arguments:
configID - the ID of the config to add the category to
categoryName - the name of the category to add
]]

function EggrollMelonAPI.ConfigGUI.AddConfigCategory(configID, categoryName)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryName] = {}
end

function EggrollMelonAPI.ConfigGUI.AddConfigOption() end

--[[
Opens the given config
Arguments:
configID - the ID of the config to be opened
]]

function EggrollMelonAPI.ConfigGUI.OpenConfig(configID)
	local configGUI = vgui.Create("EggrollMelonAPI_ConfigGUI")
	configGUI:AddCategories(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].categories)
end

--[[
Sends the new config options to the server. The saveTable should only contain a table of values of the config options that have the optionID as their keys
Arguments:
configID - the ID of the config to be saved
]]

function EggrollMelonAPI.ConfigGUI.SendConfig(configID)
	local saveString = util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable)
	
	net.Start("EggrollMelonAPI_SendNewConfiguration")
	net.WriteString(configID)
	net.WriteString(saveString)
	net.SendToServer()
end

net.Receive("EggrollMelonAPI_OpenConfig", function()
	local configID = net.ReadString()
	local configData = net.ReadString()
	local optionsTable
	
	if configData ~= "" then
		optionsTable = util.JSONToTable(configData)
	end
	
	--parse the optionsTable to use for EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options, see structure in sv_configgui_base.lua
	--[[the EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options table should have the following structure

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options table = {
		["optionCategory"] = {
			["optionID"] = {
				["optionType"] = string,
				["restrictions"] = table,
				["currentValue"] = any
			}
		}
	}

	]]

	EggrollMelonAPI.ConfigGUI.OpenConfig(configID)
end)
