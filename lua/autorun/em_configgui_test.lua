EggrollMelonAPI.ConfigGUI.RegisterConfig("Test", "test", "testconfig", "Default Category", {}, {76561198136289109}, "testconfig")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "Test Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "Idk Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "ATest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "GgdfTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "CdghTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "IujTest Category")


local optionTable = {
	{
		optionID = "test",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption",
		optionType = "NumSlider",
		optionCategory = "GgdfTest Category",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 0
	},
	{
		optionID = "test2",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption2",
		optionType = "NumSlider",
		optionCategory = "CdghTest Category",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 6,
		priority = 1
	},
	{
		optionID = "test3",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption3",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 6,
		priority = 3
	},
	{
		optionID = "test4",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption4",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 2
	},

	{
		optionID = "test5",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption5",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 4
	},

	{
		optionID = "test6",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption6",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 5
	},

	{
		optionID = "test7",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption7",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 6
	},

	{
		optionID = "test8",
		optionText = "What roles should be prevented from going AFK",
		optionName = "testOption8",
		optionType = "NumSlider",
		optionData = {
			min = 1,
			max = 10,
			decimals = 0,
		},
		defaultValue = 5,
		priority = 7
	},
}

for k, v in ipairs(optionTable) do
	EggrollMelonAPI.ConfigGUI.AddConfigOption("test", v)
end