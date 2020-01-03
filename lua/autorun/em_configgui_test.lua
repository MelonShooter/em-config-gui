EggrollMelonAPI.ConfigGUI.RegisterConfig("Test", "test", "testconfig", {}, {76561198136289109}, "testconfig")

local optionTable = {
	optionID = "test",
	optionText = "What roles should be prevented from going AFK",
	optionName = "testOption",
	optionType = "NumSlider",
	optionData = {
		min = 0,
		max = 10,
		decimals = 1
	},
	defaultValue = 5
}

EggrollMelonAPI.ConfigGUI.AddConfigOption("test", optionTable)