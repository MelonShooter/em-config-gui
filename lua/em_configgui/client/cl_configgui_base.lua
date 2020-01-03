--[[
LOCALIZATION CAPABILITIES
RESET TO DEFAULT BUTTON
]]

EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
EggrollMelonAPI.ConfigGUI.ActiveConfigs = EggrollMelonAPI.ConfigGUI.ActiveConfigs or {}
EggrollMelonAPI.ConfigGUI.ConfigTable = EggrollMelonAPI.ConfigGUI.ConfigTable or {}

--[[
Registers a config GUI
Arguments:
addonName - Name of the addon to display in the config
configID - string identifier to create config options
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, consoleCommand)
	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].consoleCommand = consoleCommand
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable = {} --table with registered tables and options (to be received and sent to server)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionsWithoutCategories = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = { --table with categories and options (for client)
		["General Config"] = {}
	}
end

--[[
Adds a category to the config
Arguments:
configID - the ID of the config to add the category to
categoryName - the name of the category to add
]]

function EggrollMelonAPI.ConfigGUI.AddConfigCategory(configID, categoryName)
	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryName] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryName] = {}
end

--[[
Opens the given config
Arguments:
configID - the ID of the config to be opened
]]

local function openConfig(configID)
	if EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] then return end

	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] = vgui.Create("EggrollMelonAPI_ConfigGUI")
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:SetConfigID(configID)
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:PopulateConfig(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options)
end

local function closeConfig(configID)
	if not EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] then return end

	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:Remove() --won't remove this properly because its pass by value
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] = nil
end

--[[
Sends the new config options to the server. The saveTable should only contain the new value of the config options that have the optionID as their keys
Arguments:
configID - the ID of the config to be saved
]]

function EggrollMelonAPI.ConfigGUI.SendConfig(configID)
	for optionID, newValue in pairs(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable) do
		if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionsWithoutCategories[optionID] == newValue then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable[optionID] = nil
		end
	end

	local saveString = util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable)

	net.Start("EggrollMelonAPI_SendNewConfiguration")
	net.WriteString(configID)
	net.WriteString(saveString)
	net.SendToServer()

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable = {}
end

net.Receive("EggrollMelonAPI_OpenConfig", function()
	local openOrClose = net.ReadBool()
	local configID = net.ReadString()

	if not openOrClose then
		closeConfig(configID)
		return
	end

	local configData = net.ReadString()

	if configData ~= "" then
		for optionID, serverOptions in pairs(util.JSONToTable(configData)) do
			local optionCategory = serverOptions.optionCategory
			serverOptions.optionCategory = nil
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID] = serverOptions
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionsWithoutCategories[optionID] = serverOptions.currentValue
		end
	end

	--[[
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {
		[optionID] = {
			["optionText"] = string,
			["optionCategory"] = string
			["optionType"] = string
			["optionData"] = table
			["currentValue"] = any
		}
	}
	]]

	--parse the optionsTable to use for EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options, see structure in sv_configgui_base.lua. the category should already be created for you once they register the category. don't create the category table yourself.
	--[[the EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options table should have the following structure

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options table = {
		["optionCategory"] = {
			["optionID"] = {
				["optionText"] = string
				["optionType"] = string
				["optionData"] = table
				["currentValue"] = any
			}
		}
	}

	]]

	openConfig(configID)
end)

--[[
These don't do anything on the client. Allows for them to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption() end
function EggrollMelonAPI.ConfigGUI.RegisterTable() end