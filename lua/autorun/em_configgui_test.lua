EggrollMelonAPI.ConfigGUI.RegisterConfig("Test", "test", "testconfig", "Default Category", {}, {76561198136289109}, "testconfig")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "Test Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "Idk Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "ATest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "GgdfTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "CdghTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test", "IujTest Category")
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
		optionType = "NumSlider",
		optionCategory = "GgdfTest Category",
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
		subsection = "testChild2",
		shared = true,
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
		optionName = "testOption3",
		parentSection = "testParent",
		shared = true,
		subsection = "testChild",
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
		}
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
		}
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
		}
	}
}

--Add a function on the server that takes these table values and assigns them to the optionText variable of each option and if the option is a dropdown menu then the rest of the strings in the table are the options in order.
--Add function on the client that adds the language into a drop down menu. upon language change, refresh all option names and drop down menu options. save this change in the client's files.
--Make addonLanguageTables as well. The language configs will 

for k, v in ipairs(optionTable) do
	EggrollMelonAPI.ConfigGUI.AddConfigOption("test", v)
end

EggrollMelonAPI.ConfigGUI.AddConfigLanguage("test", configLanguageTable)






EggrollMelonAPI.ConfigGUI.RegisterConfig("Test", "test50", "test50config", "Default Category", {}, {76561198136289109}, "test50config")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "Test Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "Idk Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "ATest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "GgdfTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "CdghTest Category")
EggrollMelonAPI.ConfigGUI.RegisterCategory("test50", "IujTest Category")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent2")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent", "testChild")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent", "testChild2")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent2", "testChild3")
EggrollMelonAPI.ConfigGUI.RegisterTable("test50", "testParent2", "testChild4")


optionTable = {
	{
		optionID = "test50",
		optionName = "testOption",
		parentSection = "testParent2",
		subsection = "testChild3",
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
		optionName = "testOption2",
		parentSection = "testParent",
		subsection = "testChild2",
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
		optionName = "testOption3",
		parentSection = "testParent",
		subsection = "testChild",
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

configLanguageTable = {
	["English"] = {
		["test50"] = {
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
		}
	},

	["Español"] = {
		["test50"] = {
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
		}
	},

	["中文 （简体字）"] = {
		["test50"] = {
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
		}
	}
}

--Add a function on the server that takes these table values and assigns them to the optionText variable of each option and if the option is a dropdown menu then the rest of the strings in the table are the options in order.
--Add function on the client that adds the language into a drop down menu. upon language change, refresh all option names and drop down menu options. save this change in the client's files.
--Make addonLanguageTables as well. The language configs will 

for k, v in ipairs(optionTable) do
	EggrollMelonAPI.ConfigGUI.AddConfigOption("test50", v)
end

EggrollMelonAPI.ConfigGUI.AddConfigLanguage("test50", configLanguageTable)
