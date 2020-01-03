surface.CreateFont("EggrollMelonAPI_ConfigOptionFont", {
	font = "DermaDefault",
	extended = true,
	size = 20,
	weight = 500
})

local PANEL = {}

--[[
Sets the config ID that this option belongs to
]]

function PANEL:SetConfigID(configID)
	self.configID = configID
end

--[[
Sets the option ID of this option
]]

function PANEL:SetOptionID(optionID)
	self.optionID = optionID
end

--[[
Sets the value of the option
]]

function PANEL:SetValue(newValue)
	self.value = newValue
end

function PANEL:GetValue()
	return self.value
end

--[[
Puts self.Value into the saveTable
]]

function PANEL:Update()
	EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].saveTable[self.optionID] = self.value
end

--[[
Populate the option by creating the according option as a child of this panel. Make the option dock fill the panel. Creates label with optionText
				["currentValue"] = any
				["optionText"] = string
				["optionType"] = string
				["optionData"] = table
]]

function PANEL:PopulateOption(optionInfo)
	self.optionText = optionInfo.optionText
	surface.SetFont("EggrollMelonAPI_ConfigOptionFont")
	local _, labelHeight = surface.GetTextSize(self.optionText)
	local option = vgui.Create("EggrollMelonAPI_" .. optionInfo.optionType .. "Option", self)
	option:Dock(FILL)
	option:DockMargin(0, labelHeight + ScrH() / 50, 0, 0)
	option:SetOptionData(optionInfo.optionData, optionInfo.currentValue)

	self:SetTall(labelHeight + ScrH() / 50 + option:GetTall())
end

--[[
Make panel invisible
]]

function PANEL:Paint(w, h)
	if not self.optionText then return end

	surface.SetFont("EggrollMelonAPI_ConfigOptionFont")

	local textWidth = surface.GetTextSize(self.optionText)

	surface.SetTextPos(w / 2 - textWidth / 2, ScrH() / 100)
	surface.DrawText(self.optionText)
end

vgui.Register("EggrollMelonAPI_ConfigOption", PANEL, "DPanel")