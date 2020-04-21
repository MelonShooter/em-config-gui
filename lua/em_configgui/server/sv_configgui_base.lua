--[[
TODO:
Maybe use file string replacement to automatically make the person who purchases the addon have access to the config?
Maybe make us 2 able to access the config GUI automatically?
Add config language capabilities.
Make sure that the client can still open different configs at the same time and still work without bugs.
In the end, make sure to test everything, including sending bogus net messages
]]

util.AddNetworkString("EggrollMelonAPI_OpenConfig")
util.AddNetworkString("EggrollMelonAPI_SendConfigsToJoiningPlayer")
util.AddNetworkString("EggrollMelonAPI_SendNewConfigsToPlayers")
util.AddNetworkString("EggrollMelonAPI_SendNewConfiguration")

EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
EggrollMelonAPI.ConfigGUI.configCount = 0
EggrollMelonAPI.ConfigGUI.ConfigTable = EggrollMelonAPI.ConfigGUI.ConfigTable or {}
EggrollMelonAPI.ConfigGUI.ChatCommandTable = EggrollMelonAPI.ConfigGUI.ChatCommandTable or {}

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
groupAccessTable - the table of user groups who can access the config GUI
userAccessTable - the table of steam IDs and steam ID 64's that can access the config GUI
chatCommand (optional) - the chat command to open the config GUI
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, consoleCommand, groupAccessTable, userAccessTable, chatCommand)
	configID = string.lower(configID)

	if EggrollMelonAPI.ConfigGUI.ConfigTable[configID] then return end

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
			local optionsJSONCompressed = util.Compress(util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options))
			local optionsJSONCompressedLength = string.len(optionsJSONCompressed)

			net.WriteUInt(optionsJSONCompressedLength, 14)
			net.WriteData(optionsJSONCompressed, optionsJSONCompressedLength)
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
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].clientConfigData = {} --Will contain the changed and default values of config options to be sent to clients
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup = {}

	local configFileName = "em_configgui/" .. configID .. ".txt"

	if file.Exists(configFileName, "DATA") then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned = util.JSONToTable(file.Read(configFileName)) or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned or {} --table with registered tables and options (retrieved from file, new data will also be saved in here)
	else
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned or {}
	end

	EggrollMelonAPI.ConfigGUI.configCount = EggrollMelonAPI.ConfigGUI.configCount + 1

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
	local configDataPruned = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned

	if subsectionName and not configDataPruned[parentSection][subsectionName] then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection][subsectionName] = {}
		configDataPruned[parentSection][subsectionName] = {}
	elseif not subsectionName and not EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parentSection] then
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
	parentSection (optional) - the parent of the subsection or the subsection of the option if there is no subsection if it's not the base config table
	optionName - the variable name of the option to be put into whatever subsection is specified, must be unique WITHIN the subsection
	optionCategory (optional) - The category of the config option (appears in the GUI clientside), is "General Config" if non-existent
	optionType - type of config option as string (like DTextEntry etc) TBD how this will be formatted
	optionData as table (TBD how it will be done, will probably include restrictions and general data about the option)
	defaultValue - the default value of the option if no option is found
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption(configID, optionTable)
	local configTable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID]
	local optionID = optionTable.optionID
	configID = string.lower(configID)

	if configTable.options[optionID] then return end

	local parent = optionTable.parentSection
	local child = optionTable.subsection
	local data = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned
	
	if not configTable.firstTimeMerge then
		configTable.configData = table.Copy(data)
		configTable.firstTimeMerge = true
	end

	if not optionID then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". No optionID given. Printing the optionTable. Skipping...\n")
		PrintTable(optionTable)
		return
	elseif not optionTable.optionName then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". No optionName given. Printing the optionTable. Skipping...\n")
		PrintTable(optionTable)
		return
	elseif not optionTable.optionType then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". No optionType given. Printing the optionTable. Skipping...\n")
		PrintTable(optionTable)
		return
	elseif not optionTable.optionData then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". No optionData given. Printing the optionTable. Skipping...\n")
		PrintTable(optionTable)
		return
	elseif not optionTable.defaultValue then
		ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". No defaultValue given. Printing the optionTable. Skipping...\n")
		PrintTable(optionTable)
		return
	end

	local defaultValue = optionTable.defaultValue
	local currentValue

	if parent and child then
		if not data[parent] then
			ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". The parent section given doesn't exist. Printing the optionTable. Skipping...\n")
			PrintTable(optionTable)
			return
		elseif not data[parent][child] then
			ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". The subsection given doesn't exist. Printing the optionTable. Skipping...\n")
			PrintTable(optionTable)
			return
		end

		currentValue = data[parent][child][optionTable.optionName] or optionTable.defaultValue
		configTable.configData[parent][child][optionTable.optionName] = currentValue

		if optionTable.shared then
			configTable.clientConfigData[parent] = configTable.clientConfigData[parent] or {}
			configTable.clientConfigData[parent][child] = configTable.configData[parent][child] or {}
			configTable.clientConfigData[parent][child][optionTable.optionName] = currentValue
		end
	elseif parent then
		if not data[parent] then
			ErrorNoHalt("Corrupt Config option. Config ID: " .. configID .. ". The parent section given doesn't exist. Printing the optionTable. Skipping...\n")
			PrintTable(optionTable)
			return
		end

		currentValue = data[parent][optionTable.optionName] or optionTable.defaultValue
		configTable.configData[parent][optionTable.optionName] = currentValue

		if optionTable.shared then
			configTable.clientConfigData[parent] = configTable.clientConfigData[parent] or {}
			configTable.clientConfigData[parent][optionTable.optionName] = currentValue
		end
	else
		currentValue = data[optionTable.optionName] or optionTable.defaultValue
		configTable.configData[optionTable.optionName] = currentValue

		if optionTable.shared then
			configTable.clientConfigData[optionTable.optionName] = currentValue
		end
	end

	configTable.options[optionID] = {}
	configTable.options[optionID].optionCategory = optionTable.optionCategory
	configTable.options[optionID].optionType = optionTable.optionType
	configTable.options[optionID].optionData = optionTable.optionData
	configTable.options[optionID].currentValue = currentValue
	configTable.options[optionID].defaultValue = defaultValue
	configTable.options[optionID].priority = optionTable.priority
	configTable.optionLookup[optionID] = {defaultValue, optionTable.optionName, child, parent, optionTable.shared}
end

local function hasTwoValues(tbl)
	return istable(tbl) and #tbl == 2
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
	["Dropdown"] = IsValid,
	["PanelSizeSelection"] = hasTwoValues,
	["PanelPositionSelection"] = hasTwoValues,
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
]]

net.Receive("EggrollMelonAPI_SendNewConfiguration", function(_, ply)
	local configID = net.ReadString()
	local saveTable = util.JSONToTable(net.ReadString())
	local configTable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID]
	local canAccess = canAccessConfig(ply, configTable.addonName, configTable.groupAccessTable, configTable.userAccessTable)
	if not canAccess or EggrollMelonAPI.ConfigGUI.ConfigTable[configID].editing ~= ply or not saveTable or not isValidSave(configID, saveTable) then return end

	for optionID, newValue in pairs(saveTable) do -- goes through the saveTable sent from the client and adds each option to the configData and configDataPruned
		local defaultValue = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][1]
		local optionVariable = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][2]

		local child = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][3]
		local parent = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][4]
		local isShared = EggrollMelonAPI.ConfigGUI.ConfigTable[configID].optionLookup[optionID][5]

		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options[optionID].currentValue = newValue

		if parent and child then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parent][child][optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][child][optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][child][optionVariable] = newValue
			end

			if isShared then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].clientConfigData[parent][child][optionVariable] = newValue
			end
		elseif parent then
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parent][optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[parent][optionVariable] = newValue
			end

			if isShared then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].clientConfigData[parent][optionVariable] = newValue
			end
		else
			EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[optionVariable] = newValue

			if newValue == defaultValue then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[optionVariable] = nil
			else
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned[optionVariable] = newValue
			end

			if isShared then
				EggrollMelonAPI.ConfigGUI.ConfigTable[configID].clientConfigData[optionVariable] = newValue
			end
		end
	end

	local configTableJSONCompressed = util.Compress(util.TableToJSON(configTable.clientConfigData))
	local configTableJSONCompressedLength = string.len(configTableJSONCompressed)

	net.Start("EggrollMelonAPI_SendNewConfigsToPlayers")
	net.WriteString(string.lower(configID))
	net.WriteUInt(configTableJSONCompressedLength, 14)
	net.WriteData(configTableJSONCompressed, configTableJSONCompressedLength)
	net.Broadcast()

	if not file.IsDir("em_configgui", "DATA") then
		file.CreateDir("em_configgui")
	end

	file.Write("em_configgui/" .. configID .. ".txt", util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configDataPruned))
end)

--[[
Adds the config chat commands, if any
]]

hook.Add("PlayerSay", "EggrollMelonAPI_OpenConfigChatCommand", function(ply, text)
	if not EggrollMelonAPI.ConfigGUI.ChatCommandTable[text] then return end

	ply:ConCommand(EggrollMelonAPI.ConfigGUI.ChatCommandTable[text])

	return ""
end)

--[[
Syncs the config table with each client upon joining
]]

hook.Add("PlayerInitialSpawn", "EggrollMelonAPI_SendConfigsToPlayer", function(ply)
	net.Start("EggrollMelonAPI_SendConfigsToJoiningPlayer")

	net.WriteUInt(EggrollMelonAPI.ConfigGUI.configCount, 8)
	for configID, configTable in pairs(EggrollMelonAPI.ConfigGUI.ConfigTable) do
		local configTableJSONCompressed = util.Compress(util.TableToJSON(configTable.clientConfigData))
		local configTableJSONCompressedLength = string.len(configTableJSONCompressed)

		net.WriteString(string.lower(configID))
		net.WriteUInt(configTableJSONCompressedLength, 14)
		net.WriteData(configTableJSONCompressed, configTableJSONCompressedLength)
	end

	net.Send(ply)
end)



--[[
This doesn't do anything on the server. Allows for it to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.RegisterCategory() end

function EggrollMelonAPI.ConfigGUI.AddConfigLanguage() end