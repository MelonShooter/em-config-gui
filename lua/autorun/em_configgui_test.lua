EggrollMelonAPI.ConfigGUI.RegisterConfig("Test", "test", "testconfig", {}, {76561198136289109}, "testconfig")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "2test")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "2test2")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "2test3")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent2")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent", "testChild")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent", "testChild2")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent2", "testChild3")
EggrollMelonAPI.ConfigGUI.RegisterTable("test", "testParent2", "testChild4")


local optionTable = {
	{
		optionID = "test",
		optionName = "testOption",
		parentSection = "testParent2",
		subsection = "testChild3",
		optionCategory = "2test",
		optionType = "NumSlider",
		shared = true,
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
		optionName = "testOption2",
		parentSection = "testParent",
		optionCategory = "2test",
		subsection = "testChild2",
		shared = true,
		optionType = "NumSlider",
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
		optionName = "testOption3",
		parentSection = "testParent",
		shared = true,
		subsection = "testChild",
		optionCategory = "2test",
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
		optionName = "testOption4",
		parentSection = "testParent2",
		subsection = "testChild4",
		optionCategory = "2test2",
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
		optionName = "testOption5",
		optionType = "NumSlider",
		shared = true,
		parentSection = "testParent",
		subsection = "testChild2",
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
		optionName = "testOption7",
		optionCategory = "2test3",
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
		optionName = "testOption8",
		optionCategory = "2test3",
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

local configLanguageTable = {
	["English"] = {
		["test"] = {
			"What roles from going AFK"
		},
		["test2"] = {
			"What roles should be from going AFK"
		},
		[ "test3" ] = {
			"What roles should be prevented from going AFK"
		},
		["test4"] = {
			"What roles should be prevented from going AFK"
		},
		[ "test5" ] = {
			"What roles should be prevented from going AFK"
		},
		["test6"] = {
			"What roles should be prevented from going AFK"
		},
		[ "test7" ] = {
			"What roles should be prevented from going AFK"
		},
		["test8"] = {
			"What roles should be prevented from going AFK"
		},
		["2test"] = "Random Category 1",
		["2test2"] = "Random Category 2",
		["2test3"] = "Random Category 3"
	},

	["Español"] = {
		["test"] = {
			"What roles should be from going AFK"
		},
		["test2"] = {
			"What roles be from going AFK"
		},
		[ "test3" ] = {
			"What roles should be from going AFK"
		},
		["test4"] = {
			"What roles should be from going AFK"
		},
		[ "test5" ] = {
			"What roles should be from going AFK"
		},
		["test6"] = {
			"What roles should be from going AFK"
		},
		[ "test7" ] = {
			"What roles should be from going AFK"
		},
		["test8"] = {
			"What roles should be from going AFK"
		},
		["2test"] = "1 Random Category 1",
		["2test2"] = "2 Random Category 2",
		["2test3"] = "3 Random Category 3"
	},

	["中文 （简体字）"] = {
		["test"] = {
			"本来是个"
		},
		["test2"] = {
			"本来是个"
		},
		[ "test3" ] = {
			"本来是个"
		},
		["test4"] = {
			"本来是个"
		},
		[ "test5" ] = {
			"本来是个"
		},
		["test6"] = {
			"本来是个"
		},
		[ "test7" ] = {
			"本来是个"
		},
		["test8"] = {
			"本来是个"
		},
		["2test"] = "1 Random Category",
		["2test2"] = "2 Random Category",
		["2test3"] = "3 Random Category"
	}
}

--Add a function on the server that takes these table values and assigns them to the optionText variable of each option and if the option is a dropdown menu then the rest of the strings in the table are the options in order.
--Add function on the client that adds the language into a drop down menu. upon language change, refresh all option names and drop down menu options. save this change in the client's files.
--Make addonLanguageTables as well. The language configs will 

for k, v in ipairs(optionTable) do
	EggrollMelonAPI.ConfigGUI.AddConfigOption("test", v)
end

EggrollMelonAPI.ConfigGUI.AddConfigLanguage("test", configLanguageTable)