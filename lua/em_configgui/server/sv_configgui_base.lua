--[[
TODO:
Maybe use file string replacement to automatically make the person who purchases the addon have access to the config?
Maybe make us 2 able to access the config GUI automatically?
Add config language capabilities.
Make sure that the client can still open different configs at the same time and still work without bugs.
In the end, make sure to test everything, including sending bogus net messages
]]

util.AddNetworkString("EggrollMelonAPI_OpenConfig")
util.AddNetworkString("EggrollMelonAPI_SendNewConfiguration")

EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
EggrollMelonAPI.ConfigGUI.ConfigTable = EggrollMelonAPI.ConfigGUI.ConfigTable or {}
EggrollMelonAPI.ConfigGUI.ChatCommandTable = {}

--[[
Checks if player can access the config GUI based on the text config.
]]

local function canAccessConfig(ply, addonName, groupAccessTable, userAccessTable)
	local userGroups = {}

	if not CAMI then
		userGroups["user"] = true

		local userTable = util.KeyValuesToTable(file.Read("settings/users.txt", "GAME")) --Get manually added user groups

		for groupName in pairs(userTable) do
			userGroups[groupName] = true
		end
	end

	for groupNumber, group in ipairs(groupAccessTable) do
		local isCAMIMatch = CAMI and CAMI.GetUserGroup(group) and CAMI.UsergroupInherits(ply:GetUserGroup(), group)
		local isMatch = isCAMIMatch or not CAMI and ply:IsUserGroup(group)
		if isstring(group) and isMatch then
			return true
		elseif not group then
			local errorMessage = "Error from the access config for " .. addonName .. ": The " .. groupNumber .. STNDRD(groupNumber) .. " user group that was inputted does not exist or was not inputted correctly. Verify that you have typed the group(s) that you want to be able to access the config GUI correctly. The groups MUST have single or double quotes at the beginning AND end. Example: \"superadmin\" or 'superadmin'. Skipping this group..."
			ErrorNoHalt(errorMessage)
		elseif not isstring(group) or CAMI and not CAMI.GetUserGroup(group) or not CAMI and not userGroups[group] then
			local errorMessage = "Error from the access config for " .. addonName .. ": The user group \"" .. groupName .. "\" was not inputted correctly. Verify that you have typed the group(s) that you want to be able to access the config GUI correctly. The groups MUST have single or double quotes at the beginning and end. Example: \"superadmin\" or 'superadmin'. Skipping this group..."
			ErrorNoHalt(errorMessage)
		end
	end

	for _, v in ipairs(userAccessTable) do
		if isnumber(v) and tonumber(ply:SteamID64()) == v or isstring(v) and (ply:SteamID64() == v or ply:SteamID() == v) then
			return true
		end
	end

	return false
end

--[[
Registers a config GUI, creating a console command to open a config GUI and the ability to create config options with the configID
Arguments:
addonName - Name of the addon to display in the config
configID - string identifier to create config options
consoleCommand - the console command to open the config GUI
defaultCategoryName - the name of the default category in the GUI
groupAccessTable - the table of user groups who can access the config GUI
userAccessTable - the table of steam IDs and steam ID 64's that can access the config GUI
chatCommand (optional) - the chat command to open the config GUI
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, consoleCommand, defaultCategoryName, groupAccessTable, userAccessTable, chatCommand)
	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID] then return end

	configID = string.lower(configID)

	concommand.Add(consoleCommand, function(ply)
		if not IsValid(ply) or not canAccessConfig(ply, addonName, groupAccessTable, userAccessTable) then return end

		local editingPlayer = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing

		if IsValid(editingPlayer) and editingPlayer ~= ply then
			ply:ChatPrint(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing:Nick() .. " is editing this config currently. Please wait until they are done.")
			return
		end

		net.Start("EggrollMelonAPI_OpenConfig") --don't do if config is currently open

		if IsValid(editingPlayer) then
			net.WriteBool(false)
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing = nil
		else
			net.WriteBool(true)
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing = ply
		end

		net.WriteString(configID)

		if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing then
			net.WriteString(util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options)) --add cooldown once this has been sent and needs to be sent again, also don't send if nothing has been changed, check against old table by creating variable in net message EggrollMelonAPI_SendNewConfiguration, make sure to check if table content is equal, not if the two tables are equal
		end

		net.Send(ply)
	end)

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = EggrollMelonAPI.ConfigGUI.ConfigTable[configID] or {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].groupAccessTable = groupAccessTable
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].userAccessTable = userAccessTable
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].consoleCommand = consoleCommand
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData = {} --Will contain all changed and default values
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].defaultCategory = defaultCategoryName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup = {}

	local configFileName = "em_configgui/" .. configID .. ".txt"

	if file.Exists(configFileName, "DATA") then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned = util.JSONToTable(file.Read(configFileName)) or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned or {} --table with registered tables and options (retrieved from file, new data will also be saved in here)
	else
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned or {}
	end

	if not chatCommand then return end

	EggrollMelonAPI.ConfigGUI.ChatCommandTable["!" .. chatCommand] = consoleCommand
end

--[[
Registers a subsection of a table for the config with a given parent or the base config table (Goes only 2 deep)
configID - string identifier to create config options
parentSection - the name of the section
subsectionName (optional) - the subsection of the parentSection
]]

function EggrollMelonAPI.ConfigGUI.RegisterTable(configID, parentSection, subsectionName)
	configID = string.lower(configID)

	if subsectionName and not EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection][subsectionName] then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection][subsectionName] = {}
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parentSection][subsectionName] = {}
	elseif not subsectionName and not EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection] then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection] = {}
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parentSection] = {}
	end
end

--function EggrollMelonAPI.ConfigGUI.AddConfigLanguage()

--[[
Adds an option to the config to the options table. Assign the config option to the given subsection in the configDataPruned table with the default value if the value doesn't exist in the file. Check if the option already exists in file, using the sub and parent section.
The options table should have this struture:
EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {
	[optionID] = {
		["optionText"] = string,
		["optionCategory"] = string
		["optionType"] = string
		["optionData"] = table
		["currentValue"] = any
	}
}
Arguments:
configID - the ID of the config to add the category to
optionTable:
	optionID - a unique identifier for the option (to be used to verify info sent from client to server, NOT TO BE PUT IN FILE)
	subsection (optional)- the subsection in the config table the option's value goes in, goes to base config table if non-existent
	parentSection (optional) - the parent of the subsection if it's not the base config table
	optionName - the variable name of the option to be put into whatever subsection is specified, must be unique WITHIN the subsection
	optionCategory (optional) - The category of the config option (appears in the GUI clientside), is "General Config" if non-existent
	optionType - type of config option as string (like DTextEntry etc) TBD how this will be formatted
	optionData as table (TBD how it will be done, will probably include restrictions and general data about the option)
	defaultValue - the default value of the option if no option is found
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption(configID, optionTable)
	local optionID = optionTable.optionID

	--if EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID] then return end

	configID = string.lower(configID)

	if not optionID or not optionTable.optionName or not
	optionTable.optionType or not optionTable.optionData or not optionTable.defaultValue then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". Skipping...")
		return
	end

	local data = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned
	local defaultValue = optionTable.defaultValue
	local currentValue

	if optionTable.parentSection and optionTable.subsection then
		currentValue = data[optionTable.parentSection][optionTable.subsection][optionTable.optionName] or optionTable.defaultValue
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[optionTable.parentSection][optionTable.subsection][optionTable.optionName] = currentValue
	elseif optionTable.parentSection then
		currentValue = data[optionTable.parentSection][optionTable.optionName] or defaultValue
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[optionTable.parentSection][optionTable.optionName] = currentValue
	else
		currentValue = data[optionTable.optionName] or defaultValue
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[optionTable.optionName] = currentValue
	end

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].optionCategory = optionTable.optionCategory or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].defaultCategory or "General Config"
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].optionType = optionTable.optionType
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].optionData = optionTable.optionData
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].currentValue = currentValue
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].defaultValue = defaultValue
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].priority = optionTable.priority
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID] = {defaultValue, optionTable.optionName, optionTable.subsection, optionTable.parentSection}
end

--[[
Returns the table of all current config values
]]

function EggrollMelonAPI.ConfigGUI.GetConfigData(configID)
	return EggrollMelonAPI.ConfigGUI.ConfigTable[string.lower(configID)].configData
end

local optionTypeToType = {
	["TextEntry"] = isstring,
	["NumberEntry"] = isnumber,
	["NumSlider"] = isnumber,
	["ColorPicker"] = IsColor,
	["Checkbox"] = isbool,
}

--[[
Check if the information taken from the client is valid. Checks if the configID and optionIDs given exist and if the types of the options make sense. Returns false if the save is invalid and true if it is valid.
]]

local function isValidSave(configID, saveTable)
	if not EggrollMelonAPI.ConfigGUI.ConfigTable[configID] or table.IsEmpty(saveTable) then
		return false
	end

	local optionTable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options

	for optionID, newValue in pairs(saveTable) do
		if not optionTable[optionID] or not optionTypeToType[optionTable[optionID].optionType](newValue) then
			return false
		end
	end

	return true
end

--[[
options table
	[optionID] = {
		["optionCategory"] = string
		["optionType"] = string
		["optionData"] = table
		["currentValue"] = any
	}
configData has the structure defined by the dev and has all default values along with changed values
configDataPruned has structure defined by dev and all non-default values

change currentValue in the options table
and change values in configData and configDataPruned then write the pruned data to the file
]]

net.Receive("EggrollMelonAPI_SendNewConfiguration", function(_, ply)
	local configID = net.ReadString()
	local saveTable = util.JSONToTable(net.ReadString())
	local configTable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID]
	local canAccess = canAccessConfig(ply, configTable.addonName, configTable.groupAccessTable, configTable.userAccessTable)
	if not canAccess or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing ~= ply or not saveTable or not isValidSave(configID, saveTable) then return end

	for optionID, newValue in pairs(saveTable) do
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].currentValue = newValue
		local defaultValue = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][1]
		local optionVariable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][2]

		local child = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][3]
		local parent = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][4]

		if parent and child then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parent][child][optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][child][optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][child][optionVariable] = newValue
			end
		elseif parent then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parent][optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][optionVariable] = newValue
			end
		else
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[optionVariable] = newValue
			end
		end

		if not file.IsDir("em_configgui", "DATA") then
			file.CreateDir("em_configgui")
		end

		file.Write("em_configgui/" .. configID .. ".txt", util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned))
	end
end)

--[[
Adds the config chat commands, if any
]]

hook.Add("PlayerSay", "EggrollMelonAPI_OpenConfigChatCommand", function(ply, text)
	if not EggrollMelonAPI.ConfigGUI.ChatCommandTable[text] then return end

	ply:ConCommand(EggrollMelonAPI.ConfigGUI.ChatCommandTable[text])
end)

--[[
This doesn't do anything on the server. Allows for it to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.RegisterCategory() end

function EggrollMelonAPI.ConfigGUI.AddConfigLanguage() end