local PANEL = {}

function PANEL:Init()
	self.Label:Dock(NODOCK)
	self.Label:SetSize(0, 0)
	self:GetTextArea():SetTextColor(Color(200, 200, 200))

end

function PANEL:SetOptionData(optionData)

end

function PANEL:Paint(w, h)

end

vgui.Register("EggrollMelonAPI_NumSliderOption", PANEL, "DNumSlider")