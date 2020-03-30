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

--[[
Called when the panel should be move back below the panel
]]

function PANEL:MoveBack()
	local savePanel = self.savePanel
	local oldSavePanelPosX = savePanel:GetPos()

	if not savePanel.isActive then return end

	self.CloseButton.disable = false

	savePanel.ready = nil --Deactivates the button from being pressed again
	savePanel.isActive = nil --Allows OnValueChange() to be able to be called again

	savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .9, .2, 0, 1, function()
		savePanel:MoveTo(oldSavePanelPosX, self:GetTall(), .2, 0, 2)
	end)
end

function PANEL:Init()
	self:MakePopup()
	self:SetNoCategoryRefresh(true)
	self:SetSizeUpdate(ScrW() * .7, ScrH() * .7)
	self.CloseButton.DoClick = function(closeButton)
		if closeButton.disable then
			self.savePanel:ColorTo(Color(60, 40, 40), .1, 0, function()
				self.savePanel:ColorTo(Color(40, 40, 40), .2)
			end)

			self:GetCurrentCategoryButton():ColorTo(Color(200, 100, 100), .1, 0, function()
				self:GetCurrentCategoryButton():ColorTo(Color(200, 200, 200), .2)
			end)

			self.CloseButton:ColorTo(Color(200, 100, 100), .1, 0, function()
				self.CloseButton:ColorTo(Color(200, 200, 200), .2)
			end)
		else
			LocalPlayer():ConCommand(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].consoleCommand)
		end
	end

	self.savePanel = vgui.Create("DPanel", self)
	self.savePanel:SetSize(self:GetWide() / 2, self:GetTall() / 15)
	self.savePanel:SetPos(self.ContentPanel:GetWide() / 2 + self.CategoriesPanel:GetWide() - self.savePanel:GetWide() / 2, self:GetTall())
	self.savePanel.SetColor = function(savePanel, color)
		savePanel.currentColor = color
		savePanel.Paint = function(_, w, h)
			draw.RoundedBox(8, 0, 0, w, h, savePanel.currentColor)
		end
	end

	self.savePanel:SetColor(Color(40, 40, 40))

	self.savePanel.GetColor = function()
		return self.savePanel.currentColor
	end

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

		self:MoveBack()

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
	end
end

function PANEL:SetConfigID(configID)
	self.configID = configID
end

--[[
Populates the config with the config values in the default category
]]

function PANEL:PopulateConfig()
	for categoryName, optionsTable in SortedPairs(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].options) do --Get updated em_configgui, use priority system here
		local categoryID = self:AddCategory(categoryName)

		self:GetCategoryButton(categoryID).DoClick = function( )
			if self:GetCurrentCategoryName() == categoryName then return end

			if self.savePanel.isActive then
				self.savePanel:ColorTo(Color(60, 40, 40), .1, 0, function()
					self.savePanel:ColorTo(Color(40, 40, 40), .2)
				end)

				self:GetCurrentCategoryButton():ColorTo(Color(200, 100, 100), .1, 0, function()
					self:GetCurrentCategoryButton():ColorTo(Color(200, 200, 200), .2)
				end)

				return
			end

			self:SetCategory(categoryID)
		end

		self:AddContentToCategory(categoryID, "DPanel", function(top)
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
			self:AddContentToCategory(categoryID, "EggrollMelonAPI_ConfigOption", function(option)
				option:SetConfigID(self.configID)
				option:SetOptionID(optionID)
				option:SetCategory(categoryName)
				option:PopulateOption(optionInfo)
			end)
		end

		self:AddContentToCategory(categoryID, "DPanel", function(bottom)
			bottom:SetTall(self:GetTall() * .1)
			bottom:SetPaintBackground(false)

			local showResetAll = false

			for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
				if option:GetName() ~= "EggrollMelonAPI_ConfigOption" or option.category ~= categoryName then continue end --Continue if the child isn't config option or doesn't belong to correct category

				if option.resetButton:IsVisible() then
					showResetAll = true

					break
				end
			end

			if showResetAll then
				self.resetAll:SetVisible(true)
			else
				self.resetAll:SetVisible(false)
			end
		end)

		if categoryName ~= (EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].defaultCategory or "General Config") then continue end

		self:SetCategory(categoryID)
	end

	self:SetTitle(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].addonName .. " Config")

	local horizontalTitleSize = self.Title:GetSize()

	local offsetX = self.Title:GetPos()

	self.LanguageSelection = vgui.Create("DComboBox", self)
	self.LanguageSelection:SetPos(offsetX + horizontalTitleSize + 7, 1)
	self.LanguageSelection:SetSize(ScrW() / 10, self:GetTall() - self.Window:GetTall() - 2)
	self.LanguageSelection.Paint = function(pnl, w, h)
		surface.SetDrawColor(Color(150, 150, 150))
		surface.DrawRect(0, 0, w, h)
	end

	--Make the language selection look better, then populate with EggrollMelonAPI.ConfigGUI.ConfigTable[configID].language
end

function PANEL:OnValueChange()
	local oldSavePanelPosX = self.savePanel:GetPos()
	local showResetAll = false
	local moveSavePanelBack = true

	for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do --If any of the reset to default buttons are visible, make the reset all to default button visible
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

		self:MoveBack()
		return
	else
		self.CloseButton.disable = true
		self.savePanel.isActive = true
	end

	self.savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .9, .2, 0, 1, function(_, savePanel)
		savePanel:MoveTo(oldSavePanelPosX, self:GetTall() * .91, .2, 0, 2, function()
			savePanel.ready = true
		end)
	end)
end

vgui.Register("EggrollMelonAPI_ConfigGUI", PANEL, "EggrollMelonAPI_DarkFrameWithCategories")