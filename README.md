ADDITIONS:

Added EggrollMelonAPI.ConfigGUI.RegisterConfig to register a config GUI

Added EggrollMelonAPI.ConfigGUI.RegisterTable

Added EggrollMelonAPI.ConfigGUI.AddConfigOption

Added chat and console command for RegisterConfig

Added EggrollMelonAPI.ConfigGUI.AddConfigCategory

Added EggrollMelonAPI.ConfigGUI.OpenConfig

Added EggrollMelonAPI.ConfigGUI.SendConfig

Added net message to retrieve data from server to populate config


PLAN:

The functions that need to be accessed by a developer creating the config dev will be shared (If one only runs server or clientside code, make the function in the other realm do nothing.)

The developer should register the config and register any tables to change the structure of the table they want to show up in the file.

Upon registering the config, the module should attempt to get the file if it exists and if it doesn't, create a blank configData table. If it does, read the file and put it in configData.

They can then add whatever config options they want into any subsection of the config that they want.

When the client tries to open the config and has sufficient permissions, the config will open and they will receive the info they need to populate the config. 

The config is populated, then when the admin is done editing and presses save, the data is sent back to the server for verification and uploading to the file and also updates the configData table.


TODO:
Read code and comments especially and understand it inside and out

Complete EggrollMelonAPI.ConfigGUI.AddConfigOption on the server so that it registers the option correctly (read the comment on the server right above this function.

IMPLEMENT THE TABLES CORRECTLY. READ ALL COMMENTS.

VERIFY THAT ALL FUNCTIONS GO ACCORDING TO THE PLAN. IF ANYTHING DEVIATES, ASK BEFORE MODIFYING.

FINISH BACKEND.

ASK ANY QUESTIONS YOU MAY HAVE.


POSSIBLE OPTIMIZATIONS
Only write a string to network if there is a change to the table and only network across the changes.
