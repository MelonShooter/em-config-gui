local PANEL = {}

local function PaintNotches(x, y, w, h, num)
	if not num then return end

	local space = w / num

	for i = 0, num do
		surface.DrawRect(x + i * space, y + 4, 1, 5)
	end
end

function PANEL:Init()
	local sliderColor = GWEN.CreateTextureNormal(416, 32, 15, 15)

	self.Label:Dock(NODOCK)
	self.Label:SetSize(0, 0)
	self:GetTextArea():SetTextColor(Color(200, 200, 200))

	self.Slider.Paint = function(slider, w, h)
		surface.SetDrawColor(Color(200, 200, 200, 100))
		surface.DrawRect(8, h / 2 - 1, w - 15, 1)
		PaintNotches(8, h / 2 - 1, w - 16, 1, slider:GetNotches())
	end

	self.TextArea.OnEnter = self.SetTextAreaOnChange
	self.TextArea.OnFocusChanged = self.SetTextAreaOnChange
	self.TextArea.Paint = function(textArea, w, h)
		textArea:DrawTextEntryText(Color(200, 200, 200), Color(30, 130, 255), Color(200, 200, 200))
	end

	self.Slider.Knob.OnMousePressed = function(_, mouseCode) --Override middle click functionality
		self.Slider:OnMousePressed(mouseCode)
	end

	self.Slider.Knob.Paint = function(pnl, w, h) --Override the knob's dragged/hovering color
		sliderColor(0, 0, w, h)
	end
end


function PANEL:OnValueChanged(newValue)
	self:SetValue(math.Round(newValue, self:GetDecimals()))

	if not self.InitialValueSet and self.OldValue and math.Round(newValue, self:GetDecimals()) ~= self.OldValue then
		self:GetParent():SetValue(math.Round(newValue, self:GetDecimals()))
	elseif self.InitialValueSet then
		self.InitialValueSet = nil
	end

	self.OldValue = self:GetValue()
end

--[[
Sets the text of the DNumSlider to the minimum or maximum if the text goes below or above them, respectively
]]

function PANEL:SetTextAreaOnChange(focusStatus)
	if focusStatus then return end

	local dNumSliderParent = self:GetParent()
	local newNumber = self:GetText()
	local newValue = tonumber(newNumber) or newNumber == "" and dNumSliderParent:GetMin()

	if not newValue then
		self:SetText(dNumSliderParent:GetValue())
		return
	elseif newValue > dNumSliderParent:GetMax() then
		self:SetText(dNumSliderParent:GetMax())
	elseif newValue < dNumSliderParent:GetMin() then
		self:SetText(dNumSliderParent:GetMin())
	else
		self:SetText(math.Round(newValue, dNumSliderParent:GetDecimals()))
	end
end

function PANEL:SetOptionData(optionData, currentValue)
	if optionData.min then
		self:SetMin(optionData.min)
	end

	if optionData.max then
		self:SetMax(optionData.max)
	end

	if optionData.decimals then
		self:SetDecimals(optionData.decimals)
	end

	self.InitialValueSet = true
	self:SetDefaultValue(currentValue)
	self:ResetToDefaultValue()
end

vgui.Register("EggrollMelonAPI_NumSliderOption", PANEL, "DNumSlider")