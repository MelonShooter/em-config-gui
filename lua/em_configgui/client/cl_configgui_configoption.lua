local PANEL = {}

function PANEL:Init()
	self:SetTall(ScrH() / 10)
end

--[[
Sets the config ID that this option belongs to
]]

function PANEL:SetConfigID(configID)
	self.ConfigID = configID
end

--[[
Sets the option ID of this option
]]

function PANEL:SetOptionID(optionID)
	self.OptionID = optionID
end

--[[
Sets the value of the option
]]

function PANEL:SetValue(newValue)
	if newValue == self.OldValue then return end

	self.Value = newValue
end

function PANEL:GetValue()
	return self.Value
end

--[[
Puts self.Value into the saveTable
]]

function PANEL:Update()
	EggrollMelonAPI.ConfigGUI.ConfigTable[self.ConfigID].saveTable[self.OptionID] = self.Value
end

--[[
Populate the option by creating the according option as a child of this panel. Make the option dock fill the panel. Creates label with optionText
				["currentValue"] = any
				["optionText"] = string
				["optionType"] = string
				["optionData"] = table
]]

function PANEL:PopulateOption(optionInfo)
	local option = vgui.Create("EggrollMelonAPI_" .. optionInfo.optionType .. "Option", self)
	option:Dock(FILL)
	option:SetOptionData(optionInfo.optionData, optionInfo.currentValue)
	self.OldValue = optionInfo.currentValue
end

--[[
Make panel invisible
]]

function PANEL:Paint()
end

vgui.Register("EggrollMelonAPI_ConfigOption", PANEL, "DPanel")