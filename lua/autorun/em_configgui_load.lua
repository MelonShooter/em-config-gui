if SERVER then
	AddCSLuaFile("em_configgui/client/cl_configgui_base.lua")
	include("em_configgui/server/sv_configgui_base.lua")
end

if CLIENT then
	include("em_configgui/client/cl_configgui_base.lua")
end
