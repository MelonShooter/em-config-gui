surface.CreateFont("EggrollMelonAPI_ConfigOptionFont", {
	font = "CloseCaption_Normal",
	extended = true,
	size = ScrW() / 96,
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

	if self.revertButton:IsVisible() and newValue == self.oldValue then
		self.revertButton:SetVisible(false)
	elseif not self.revertButton:IsVisible() and newValue ~= self.oldValue then
		self.revertButton:SetVisible(true)
	end

	if self.resetButton:IsVisible() and newValue == self.defaultValue then
		self.resetButton:SetVisible(false)
	elseif not self.resetButton:IsVisible() and newValue ~= self.defaultValue then
		self.resetButton:SetVisible(true)
	end

	local configGUIPanel = self:GetParent().DarkFrame
	configGUIPanel:OnValueChange()
end

function PANEL:GetValue()
	return self.value
end

--[[
Puts self.Value into the saveTable
]]

function PANEL:Update()
	if not self.value then return end

	EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].saveTable[self.optionID] = self.value
	self.oldValue = self.value
	self.revertButton:SetVisible(false)
end

local function resetTrueHeight(panel)
	local totalHeight = 0

	for _, child in ipairs(panel:GetChildren()) do
		local _, topMargin, _, bottomMargin = child:GetDockMargin()
		totalHeight = totalHeight + topMargin + bottomMargin + child:GetTall()
	end

	panel:SetTall(totalHeight)
end

--[[
Populate the option by creating the according option as a child of this panel. Make the option dock fill the panel. Creates label with optionText
				["currentValue"] = any
				["optionText"] = string
				["optionType"] = string
				["optionData"] = table
]]

function PANEL:PopulateOption(optionInfo)
	self.defaultValue = optionInfo.defaultValue
	self.oldValue = optionInfo.currentValue
	self.optionText = optionInfo.optionText .. " (Default: " .. self.defaultValue .. ")"

	surface.SetFont("EggrollMelonAPI_ConfigOptionFont")
	local _, labelHeight = surface.GetTextSize(self.optionText)

	local utilityPanel = vgui.Create("DPanel", self)
	utilityPanel:SetSize(0, ScrH() / 60)
	utilityPanel:Dock(TOP)
	utilityPanel:DockMargin(ScrW() / 50, labelHeight + ScrH() / 40, ScrW() / 50, ScrH() / 200)
	utilityPanel:SetPaintBackground(false)

	self.resetButton = vgui.Create("DButton", utilityPanel)
	self.resetButton:SetFont("EggrollMelonAPI_ConfigRevertButtonFont")
	self.resetButton:SetTextColor(Color(150, 150, 150))
	self.resetButton:SetText("Reset to default value")
	self.resetButton:SizeToContents()
	self.resetButton:Dock(LEFT)
	self.resetButton:SetPaintBackground(false)
	self.resetButton.DoClick = function()
		if not self.option then return end

		self.option:SetValue(self.defaultValue)
	end

	if self.defaultValue == optionInfo.currentValue then
		self.resetButton:SetVisible(false)
	end

	self.revertButton = vgui.Create("DButton", utilityPanel)
	self.revertButton:SetFont("EggrollMelonAPI_ConfigRevertButtonFont")
	self.revertButton:SetTextColor(Color(150, 150, 150))
	self.revertButton:SetText("Revert Changes")
	self.revertButton:SizeToContents()
	self.revertButton:Dock(RIGHT)
	self.revertButton:SetPaintBackground(false)
	self.revertButton:SetVisible(false)
	self.revertButton.DoClick = function()
		if not self.option then return end

		self.option:SetValue(self.oldValue)
	end

	self.option = vgui.Create("EggrollMelonAPI_" .. optionInfo.optionType .. "Option", self)
	self.option:Dock(FILL)
	self.option:DockMargin(ScrW() / 100, 0, ScrW() / 100, ScrH() / 100)
	self.option:SetOptionData(optionInfo.optionData, optionInfo.currentValue)

	local marginPanel = vgui.Create("DPanel", self)
	marginPanel:SetSize(0, ScrH() / 30)
	marginPanel:Dock(BOTTOM)
	marginPanel.Paint = function(_, w, h)
		surface.SetDrawColor(Color(50, 50, 50, 100))
		surface.DrawRect(0, h - ScrH() / 800, w, ScrH() / 800)
	end

	resetTrueHeight(self)
end

--[[
Adds the option text
]]

function PANEL:Paint(w, h)
	if not self.optionText then return end

	surface.SetFont("EggrollMelonAPI_ConfigOptionFont")

	local textWidth = surface.GetTextSize(self.optionText)

	surface.SetTextColor(Color(200, 200, 200))
	surface.SetTextPos(w / 2 - textWidth / 2, ScrH() / 50)
	surface.DrawText(self.optionText)
end

vgui.Register("EggrollMelonAPI_ConfigOption", PANEL, "DPanel")