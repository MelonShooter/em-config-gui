--[[
TODO:
Maybe use file string replacement to automatically make the person who purchases the addon have access to the config?
Maybe make us 2 able to access the config GUI automatically?
Create config base panel which will accept table to create the config procedurally
Create config elements that can be created
Add config language capabilities.
Make sure to prune the files for extraneous config options if they no longer exist
]]

util.AddNetworkString("EggrollMelonAPI_OpenConfig")
util.AddNetworkString("EggrollMelonAPI_SendNewConfiguration")

EggrollMelonAPI = EggrollMelonAPI or {}
EggrollMelonAPI.ConfigGUI = EggrollMelonAPI.ConfigGUI or {}
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
groupAccessTable - the table of user groups who can access the config GUI
userAccessTable - the table of steam IDs and steam ID 64's that can access the config GUI
consoleCommand - the console command to open the config GUI
chatCommand (optional) - the chat command to open the config GUI
]]

function EggrollMelonAPI.ConfigGUI.RegisterConfig(addonName, configID, groupAccessTable, userAccessTable, consoleCommand, chatCommand)
	concommand.Add(consoleCommand, function(ply)
		if not IsValid(ply) or not canAccessConfig(ply, addonName, groupAccessTable, userAccessTable) then return end
		
		net.Start("EggrollMelonAPI_OpenConfig")
		net.WriteString(configID)
		net.WriteString(util.TableToJSON(EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options)) --add cooldown once this has been sent, also don't send if nothing has been changed
		net.Send(ply)
	end)

	EggrollMelonAPI.ConfigGUI.ConfigTable[configID] = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {}
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].addonName = addonName
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].groupAccessTable = groupAccessTable
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].userAccessTable = userAccessTable
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].consoleCommand = consoleCommand
	
	EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData = {util.JSONToTable(file.Read("em_configgui/" .. configID .. ".txt"))} --table with registered tables and options (retrieved from file, new data will also be saved in here)
	
	if not chatCommand then return end

	EggrollMelonAPI.ConfigGUI.ChatCommandTable["!" .. chatCommand] = consoleCommand
end

--[[
Registers a subsection of a table for the config with a given parent or the base config table (Goes only 2 deep)
configID - string identifier to create config options
subsectionName - the subsection of the table to be registered
parentSection  (optional) - the parent of the subsection
]]

function EggrollMelonAPI.ConfigGUI.RegisterTable(configID, subsectionName, parentSection)
	if parentSection then
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[parentSection][subsectionName] = {}
	else
		EggrollMelonAPI.ConfigGUI.ConfigTable[configID].configData[subsectionName] = {}
	end
end

--[[
Adds an option to the config to the options table. Assign the config option to the given subsection in the configData table with the default value if the value doesn't exist in the file.
The options table should have this struture:
EggrollMelonAPI.ConfigGUI.ConfigTable[configID].options = {
	[optionID] = {
		["optionText"] = string,
		["optionCategory"] = string
		["optionType"] = string
		["restrictions"] = table
		["currentValue"] = any
	}
}
Arguments:
configID - the ID of the config to add the category to
configOptionTable:
	optionID - a unique identifier for the option (to be used to verify info sent from client to server, NOT TO BE PUT IN FILE)
	optionText - the text of the option to add
	subsection - the subsection in the config table the option's value goes in
	parentSection (optional) - the parent of the subsection if it's not the base config table
	optionCategory (optional) - The category of the config option (to appear in the GUI clientside)
	optionName - the variable name of the option to be put into whatever subsection is specified, must be unique WITHIN the subsection
	optionType - type of config option as string (like DTextEntry etc) TBD how this will be formatted
	restrictions as table (TBD how it will be done)
	defaultValue - the default value of the option if no option is found
]]

function EggrollMelonAPI.ConfigGUI.AddConfigOption(configID, configOptionTable)
	
end

--[[
Adds the config chat commands, if any
]]

hook.Add("PlayerSay", "EggrollMelonAPI_OpenConfig", function(_, text)
	if not EggrollMelonAPI.ConfigGUI.ChatCommandTable[text] then return end

	ply:ConCommand(EggrollMelonAPI.ConfigGUI.ChatCommandTable[text])
end)

--[[
This doesn't do anything on the server. Allows for it to be called in the shared realm
]]

function EggrollMelonAPI.ConfigGUI.AddConfigCategory(configID, categoryName) end