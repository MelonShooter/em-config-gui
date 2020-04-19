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
local normalComboBox
local clickedComboBox

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
	normalComboBox = GWEN.CreateTextureNormal(496, 272 + 32, 15, 15)
	clickedComboBox = GWEN.CreateTextureNormal(496, 272, 15, 15)

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

local function drawHoverButton(btn, w, h)
	surface.SetDrawColor(Color(200, 200, 200))
	surface.DrawRect(0, 0, w, h)

	if btn:IsHovered() then
		if not btn.hoverlerp then
			btn.hoverlerp = 0
		elseif btn.hoverlerp < 1 then
			btn.hoverlerp = btn.hoverlerp + 0.075
		end

		surface.SetDrawColor(Color(220, 220, 220))
		surface.DrawRect(0, 0, Lerp(btn.hoverlerp, 0, btn:GetWide()), h)
	elseif btn.hoverlerp then
		btn.hoverlerp = btn.hoverlerp - 0.075

		surface.SetDrawColor(btn.HoverColor or Color(220, 220, 220))
		surface.DrawRect( 0, 0, Lerp(btn.hoverlerp, 0, btn:GetWide()), h)

		if btn.hoverlerp <= 0 then
			btn.hoverlerp = nil
		end
	end
end

--[[
Populates the config with the config values in the default category
]]

function PANEL:PopulateConfig()
	for categoryID, optionsTable in SortedPairs(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].options) do
		local configLanguageSetting = file.Read("eggrollmelonapi/configgui/" .. self.configID .. "language.txt")
		local configLanguage = EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[configLanguageSetting] and configLanguageSetting or "English"
		local configLanguageTable = EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[configLanguage] or EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language["English"]
		local categoryName = configLanguageTable[categoryID] or categoryID == "general" and EggrollMelonAPI.ConfigGUI.Language[configLanguage][1]

		if not categoryName then continue end

		local categoryGUIID = self:AddCategory(categoryName)

		self:GetCategoryButton(categoryGUIID).DoClick = function( )
			if self:GetCurrentCategoryID() == categoryGUIID then return end

			if self.savePanel.isActive then
				self.savePanel:ColorTo(Color(60, 40, 40), .1, 0, function()
					self.savePanel:ColorTo(Color(40, 40, 40), .2)
				end)

				self:GetCurrentCategoryButton():ColorTo(Color(200, 100, 100), .1, 0, function()
					self:GetCurrentCategoryButton():ColorTo(Color(200, 200, 200), .2)
				end)

				return
			end

			self:SetCategory(categoryGUIID)
		end

		self:AddContentToCategory(categoryGUIID, "DPanel", function(top)
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
			self:AddContentToCategory(categoryGUIID, "EggrollMelonAPI_ConfigOption", function(option)
				option:SetConfigID(self.configID)
				option:SetOptionID(optionID)
				option:SetCategory(categoryID)
				option:PopulateOption(optionInfo)
			end)
		end

		self:AddContentToCategory(categoryGUIID, "DPanel", function(bottom)
			bottom:SetTall(self:GetTall() * .1)
			bottom:SetPaintBackground(false)

			local showResetAll = false

			for _, option in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do
				if option:GetName() ~= "EggrollMelonAPI_ConfigOption" or option.categoryID ~= categoryID then continue end --Continue if the child isn't config option or doesn't belong to correct category

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

		if categoryName ~= (EggrollMelonAPI.ConfigGUI.Language[configLanguage][1] or EggrollMelonAPI.ConfigGUI.Language["English"][1]) then continue end

		self:SetCategory(categoryGUIID)
	end

	self:RemoveCategoriesIfEmpty()

	self:SetTitle(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].addonName .. " Config")

	local configLanguage = file.Read("eggrollmelonapi/configgui/" .. self.configID .. "language.txt")  or "English"

	self.LanguageSelection = vgui.Create("DComboBox", self)
	self.LanguageSelection:SetPos(self:GetWide() * 0.82, 2)
	self.LanguageSelection:SetValue(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[configLanguage] and configLanguage or "English")
	self.LanguageSelection:SetSize(ScrW() / 10, self:GetTall() - self.Window:GetTall() - 4)
	self.LanguageSelection:SetTextColor(Color(200, 200, 200))
	self.LanguageSelection.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100))
	end

	self.LanguageSelection.DropButton.Paint = function(panel, w, h)
		if panel.ComboBox.Depressed or panel.ComboBox:IsMenuOpen() then
			return clickedComboBox(0, 0, w, h)
		end

		normalComboBox(0, 0, w, h)
	end

	self.LanguageSelection.DoClick = function()
		if (self.LanguageSelection:IsMenuOpen()) then
			return self.LanguageSelection:CloseMenu()
		end

		self.LanguageSelection:OpenMenu()

		if self.LanguageSelection.Menu then
			for _, v in ipairs(self.LanguageSelection.Menu:GetCanvas():GetChildren()) do
				v.Paint = drawHoverButton
			end
		end
	end

	for languageName in pairs(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language) do
		self.LanguageSelection:AddChoice(languageName)
	end

	self.LanguageSelection.OnSelect = function(_, __, value) --Write new language preference to client's files and reload language files
		if not file.Exists("eggrollmelonapi", "DATA") then
			file.CreateDir("eggrollmelonapi")
		end

		if not file.Exists("eggrollmelonapi/configgui", "DATA") then
			file.CreateDir("eggrollmelonapi/configgui")
		end

		file.Write("eggrollmelonapi/configgui/" .. self.configID .. "language.txt", value)

		for _, optionsTable in SortedPairs(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].options) do  --Changes language of text in all categories but doesn't refresh current category
			for optionID, optionInfo in pairs(optionsTable) do
				optionInfo.optionText = EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[value][optionID][1]

				if optionInfo.optionType == "Dropdown" then
					optionInfo.optionData.dropdownOptions = EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[value][optionID][2]
				end
			end
		end

		for k, v in ipairs(self.ContentDScrollPanel:GetCanvas():GetChildren()) do --Changes language of text of options in current category
			if v:GetName() ~= "EggrollMelonAPI_ConfigOption" then continue end

			v.optionText = EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].language[value][v.optionID][1]
		end
	end
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