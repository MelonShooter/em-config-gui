--[[
When something is edited within a category, make a popup coming from the bottom to save or revert changes like discord does.
Don't let them leave category until they save. Maybe make the popup flash red when they try.
Add something at the drop down menu at the top right to change languages, Maybe put a universal symbol up there.
]]

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self:SetSizeUpdate(ScrW() * .7, ScrH() * .7)
	self.CloseButton.DoClick = function()
		LocalPlayer():ConCommand(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].consoleCommand)
	end
end

function PANEL:SetConfigID(configID)
	self.configID = configID
end

function PANEL:PopulateConfig(configInfo)
	for category, optionsTable in pairs(configInfo) do
		self:AddCategory(category)

		for optionID, optionInfo in pairs(optionsTable) do
			self:AddContentToCategory(category, "EggrollMelonAPI_ConfigOption", function(option)
				option:SetOptionID(optionID)
				option:PopulateOption(optionInfo)
			end)
		end
	end

	self:SetTitle(EggrollMelonAPI.ConfigGUI.ConfigTable[self.configID].addonName .. " Config")
	self:SetCategory("General Config")
end

vgui.Register("EggrollMelonAPI_ConfigGUI", PANEL, "EggrollMelonAPI_DarkFrameWithCategories")