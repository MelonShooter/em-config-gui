--[[
Add something at the drop down menu at the top left, after title, to change languages, Maybe put a universal symbol up there.
LOCALIZATION CAPABILITIES

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
consoleCommand - the console command to open the config GUI
defaultCategoryName - the name of the default category in the GUI
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, consoleCommand, defaultCategoryName)
	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].consoleCommand = consoleCommand
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].defaultCategory = defaultCategoryName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].saveTable = {} --table with registered tables and options (to be received and sent to server)
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = { --table with categories and options (for client)
		[EggrollMelonAPI.ConfigGUI.ConfigTable[configID].defaultCategory or "General Config"] = {}
	}
end

--[[
Adds a category to the config
Arguments:
configID - the ID of the config to add the category to
categoryName - the name of the category to add
]]

function EggrollMelonAPI.ConfigGUI.RegisterCategory(configID, categoryName)
	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryName] then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[categoryName] = {}
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
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language = configLanguageTable
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
	EggrollMelonAPI.ConfigGUI.ActiveConfigs[configID]:PopulateConfig()
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
		local configLanguage = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language[file.Read("eggrollmelonapi/configgui/language.txt") or "English"]
		for optionID, serverOptions in pairs(util.JSONToTable(configData)) do
			local optionCategory = serverOptions.optionCategory
			serverOptions.optionCategory = nil --Why?
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID] = serverOptions
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionText = configLanguage[optionID][1]

			if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionType == "Dropdown" then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionCategory][optionID].optionData.dropdownOptions = configLanguage[optionID][2] --For dropdown menus, the menu's options need to be gotten from the language table
			end
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
These don't do anything on the client. Allows for them to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption() end
function EggrollMelonAPI.ConfigGUI.RegisterTable() end