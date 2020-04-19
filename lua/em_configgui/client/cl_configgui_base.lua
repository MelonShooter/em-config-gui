--[[
Add something at the drop down menu at the top left, after title, to change languages, Maybe put a universal symbol up there.
LOCALIZATION CAPABILITIES
]]

EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
EggrollMelonAPI.ConfigGUI.ActiveConfigs = EggrollMelonAPI.ConfigGUI.ActiveConfigs or {}
EggrollMelonAPI.ConfigGUI.ConfigTable = EggrollMelonAPI.ConfigGUI.ConfigTable or {}
EggrollMelonAPI.ConfigGUI.Language = {
	["English"] = {
		"General Settings",
		"Reset category to default values",
		"Reset to default value",
		"Revert unsaved changes to setting",
		"Revert all unsaved changes",
		"You have unsaved changes.",
		"Save changes"
	},
	["Español"] = {
		"Ajustes Generales",
		"Restaurar categoría a valores por defecto",
		"Restaurar el valor por defecto",
		"Deshacer cambio de ajuste no guardado",
		"Deshacer todos los cambios no guardados",
		"Tienes cambios no guardados.",
		"Guardar cambios"
	},
	["中文 （简体字）"] = {
		"General Config",
		"Reset category to default values",
		"Reset to default value",
		"Revert unsaved changes to setting",
		"Revert all unsaved changes",
		"You have unsaved changes.",
		"Save changes"
	}
}

--[[
Registers a config GUI
Arguments:
addonName - Name of the addon to display in the config
configID - string identifier to create config options
consoleCommand - the console command to open the config GUI
defaultCategoryName - the name of the default category in the GUI
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, consoleCommand)
	configID = string.lower(configID)

	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].consoleCommand = consoleCommand
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable = {} --table with registered tables and options (to be received and sent to server)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {
		["general"] = {}
	} --table with categories and options (for client)
end

--[[
Adds a category to the config
Arguments:
configID - the ID of the config to add the category to
categoryID - the ID of the category to add
]]

function EggrollMelonAPI.ConfigGUI.RegisterCategory(configID, categoryID)
	configID = string.lower(configID)

	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryID] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryID] = {}
end

--[[
Adds a language to the config
Arguments:
configID - the ID of the config to be opened
configLanguageTable:
	[languageName] = {
		[optionID] = {
			optionText = string
			dropdownOptions = table (optional)
		}
	}
]]

function EggrollMelonAPI.ConfigGUI.AddConfigLanguage(configID, configLanguageTable)
	configID = string.lower(configID)

	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language = configLanguageTable
end

--[[
Opens the given config
Arguments:
configID - the ID of the config to be opened
]]

local function openConfig(configID)
	configID = string.lower(configID)

	if EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] then return end

	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID] = vgui.Create("EggrollMelonAPI_ConfigGUI")
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:SetConfigID(configID)
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:PopulateConfig()
end

local function closeConfig(configID)
	configID = string.lower(configID)

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
	configID = string.lower(configID)

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

	local configDataLength = net.ReadUInt(14)

	if configDataLength == 0 then return end

	local configDataTable = util.JSONToTable(util.Decompress(net.ReadData(configDataLength)))
	local configLanguage = file.Read("eggrollmelonapi/configgui/" .. string.lower(configID) .. "language.txt") or "English"
	local configLanguageTable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language[configLanguage] or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language["English"]

	for optionID, serverOptions in pairs(configDataTable) do
		local optionCategory = serverOptions.optionCategory or "general"
		if not EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory] then
			error("The category ID: " .. optionCategory .. " doesn't exist in the options table. Was it created?")
		end
		serverOptions.optionCategory = nil --Not used after this is done
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID] = serverOptions
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionText = configLanguageTable[optionID][1]

		if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionType == "Dropdown" then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionData.dropdownOptions = configLanguageTable[optionID][2] --For dropdown menus, the menu's options need to be gotten from the language table
		end
	end

	--[[
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {
		[optionID] = {
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
Returns the table of all current config values
]]

function EggrollMelonAPI.ConfigGUI.GetConfigData(configID)
	return EggrollMelonAPI.ConfigGUI.ConfigTable[string.lower(configID)].configData
end

--[[
Syncs the config table with each client upon joining
]]

net.Receive("EggrollMelonAPI_SendConfigsToJoiningPlayer", function()
	for i = 1, net.ReadUInt(8) do
		local configID = net.ReadString()
		local configDataLength = net.ReadUInt(14)
		local configDataTable = util.JSONToTable(util.Decompress(net.ReadData(configDataLength)))

		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData = configDataTable
	end
end)

--[[
Syncs the config table when a person with access to the config saves some changes
]]

net.Receive("EggrollMelonAPI_SendNewConfigsToPlayers", function()
	local configID = net.ReadString()
	local configDataLength = net.ReadUInt(14)
	local configDataTable = util.JSONToTable(util.Decompress(net.ReadData(configDataLength)))

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData = configDataTable
end)

--[[
These don't do anything on the client. Allows for them to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption() end

function EggrollMelonAPI.ConfigGUI.RegisterTable() end