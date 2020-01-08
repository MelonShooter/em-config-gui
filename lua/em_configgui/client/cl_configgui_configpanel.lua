surface.CreateFont("EggrollMelonAPI_ConfigSaveButtonFont", {
	font = "Trebuchet24",
	extended = true,
	size = ScrW() / 120,
	weight = 700
})

surface.CreateFont("EggrollMelonAPI_ConfigRevertButtonFont", {
	font = "Trebuchet24",
	extended = true,
	size = ScrW() / 140,
	weight = 700
})

surface.CreateFont("EggrollMelonAPI_ConfigSaveTextFont", {
	font = "Trebuchet24",
	extended = true,
	size = ScrW() / 100,
	weight = 700
})

local PANEL = {}

function PANEL:MoveBack(button, oldSavePanelPosX)
	local savePanel = button:GetParent()

	if not savePanel.isActive then return end

	savePanel.ready = nil --Deactivates the button from being pressed again
	savePanel.isActive = nil --Allows OnValueChange() to be able to be called again

	savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .9, .2, 0, 2, function()
		savePanel:MoveTo(oldSavePanelPosX, self:GetTall(), .2, 0, 1)
	end)
end

function PANEL:Init()
	self:MakePopup()
	self:SetSizeUpdate(ScrW() * .7, ScrH() * .7)
	self.CloseButton.DoClick = function()
		LocalPlayer():ConCommand(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].consoleCommand)
	end

	self.savePanel = vgui.Create("DPanel", self)
	self.savePanel:SetSize(self:GetWide() / 2, self:GetTall() / 15)
	self.savePanel:SetPos(self.ContentPanel:GetWide() / 2 + self.CategoriesPanel:GetWide() - self.savePanel:GetWide() / 2, self:GetTall())
	self.savePanel.Paint = function(savePanel, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40))
	end

	local oldSavePanelPosX = self.savePanel:GetPos()

	self.saveLabel = vgui.Create("DLabel", self.savePanel)
	self.saveLabel:SetFont("EggrollMelonAPI_ConfigSaveTextFont")
	self.saveLabel:SetTextColor(Color(170, 170, 170))
	self.saveLabel:SetText("You have unsaved changes.")
	self.saveLabel:SizeToContents()
	self.saveLabel:Center()


	self.saveButton = vgui.Create("DButton", self.savePanel)
	self.saveButton:SetSize(self:GetWide() / 12, self:GetTall() / 25)
	self.saveButton:SetPos(self.savePanel:GetWide() - self.saveButton:GetWide() - ScrW() / 100, self.savePanel:GetTall() / 2 - self.saveButton:GetTall() / 2)
	self.saveButton:SetFont("EggrollMelonAPI_ConfigSaveButtonFont")
	self.saveButton:SetTextColor(Color(200, 200, 200))
	self.saveButton:SetText("Save Changes")
	self.saveButton.Paint = function(savePanel, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60))
	end

	self.saveButton.DoClick = function(saveButton)
		if not self.savePanel.ready then return end

		self:MoveBack(saveButton, oldSavePanelPosX)

		for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
			if option:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end
			option:Update()
		end

		EggrollMelonAPI.ConfigGUI.SendConfig(self.configID)
	end

	self.revertButton = vgui.Create("DButton", self.savePanel)
	self.revertButton:SetSize(self:GetWide() / 12, self:GetTall() / 35)
	self.revertButton:SetPos(ScrW() / 100, self.savePanel:GetTall() / 2 - self.revertButton:GetTall() / 2)
	self.revertButton:SetFont("EggrollMelonAPI_ConfigRevertButtonFont")
	self.revertButton:SetTextColor(Color(150, 150, 150))
	self.revertButton:SetText("Revert All Changes")
	self.revertButton.Paint = function()
	end

	self.revertButton.DoClick = function(revertButton)
		if not self.savePanel.ready then return end

		for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
			if option:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end

			if option.revertButton:IsVisible() then
				option.option:SetValue(option.oldValue)
			end
		end

		self:MoveBack(revertButton, oldSavePanelPosX)
	end
end

function PANEL:SetConfigID(configID)
	self.configID = configID
end

function PANEL:PopulateConfig(configInfo)
	for category, optionsTable in pairs(configInfo) do
		self:AddCategory(category)

		self:AddContentToCategory(category, "DPanel", function(top)
			top:SetTall(self:GetTall() * .05)
			top:SetPaintBackground(false)
			top.Paint = function(_, w, h)
				surface.SetDrawColor(Color(50, 50, 50, 100))
				surface.DrawRect(0, h - ScrH() / 800, w, ScrH() / 800)
			end

			self.resetAll = vgui.Create("DButton", top)
			self.resetAll:SetFont("EggrollMelonAPI_ConfigRevertButtonFont")
			self.resetAll:SetTextColor(Color(150, 150, 150))
			self.resetAll:SetText("Reset category to default values")
			self.resetAll:SizeToContents()
			self.resetAll:SetPos(ScrW() / 100, 0)
			self.resetAll:CenterVertical(.4)
			self.resetAll:SetVisible(false)
			self.resetAll:SetPaintBackground(false)
			self.resetAll.DoClick = function()
				for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
					if option:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end

					option.option:SetValue(option.defaultValue)
				end
			end
		end)

		for optionID, optionInfo in SortedPairsByMemberValue(optionsTable, "priority", false) do
			self:AddContentToCategory(category, "EggrollMelonAPI_ConfigOption", function(option)
				option:SetConfigID(self.configID)
				option:SetOptionID(optionID)
				option:PopulateOption(optionInfo)
			end)
		end

		self:AddContentToCategory(category, "DPanel", function(bottom)
			bottom:SetTall(self:GetTall() * .1)
			bottom:SetPaintBackground(false)
		end)
	end

	self:SetTitle(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].addonName .. " Config")
	self:SetCategory("General Config")

	local showResetAll = false

	for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
		if option:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end
		if not self.resetAll:IsVisible() and not showResetAll and option.resetButton:IsVisible() then
			showResetAll = true
		end
	end

	if showResetAll then
		self.resetAll:SetVisible(true)
	else
		self.resetAll:SetVisible(false)
	end
end

function PANEL:OnValueChange()
	local oldSavePanelPosX = self.savePanel:GetPos()
	local showResetAll = false
	local moveSavePanelBack = true

	for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
		if option:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end

		if not showResetAll and option.resetButton:IsVisible() then
			showResetAll = true
		end

		if not self.savePanel.isActive or not option.revertButton:IsVisible() then continue end

		moveSavePanelBack = false
	end

	if showResetAll then
		self.resetAll:SetVisible(true)
	else
		self.resetAll:SetVisible(false)
	end

	if self.savePanel.isActive then
		if not moveSavePanelBack then return end --If a revert button is visible, then don't do anything, otherwise move the panel back down

		self:MoveBack(self.revertButton, oldSavePanelPosX)
		return
	else
		self.savePanel.isActive = true
	end

	self.savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .9, .2, 0, 1, function(_, savePanel)
		savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .91, .2, 0, 2, function()
			savePanel.ready = true
		end)
	end)
end

vgui.Register("EggrollMelonAPI_ConfigGUI", PANEL, "EggrollMelonAPI_DarkFrameWithCategories")