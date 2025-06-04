--strict

--[[
{
	chance : percentage of how likely that map will be choosen
	Map : map module that is to be loaded if slected
}

]]

local MapConfig = {}

local MapModules = script

MapConfig.Data = {
	[1] = {
		{
			Chance = 100,
			Map = MapModules.Intro,
		},
	}, --start

	--[[
	[2] = {
		{
			Chance = 100,
			Map = MapModules.ApartmentStart,
		},
	},

	[3] = {
		{
			Chance = 100,
			Map = MapModules.ApartmentStreet,
		},
	},

	[1000] = {
		{
			Chance = 100,
			Map = MapModules.Outro,
		},
	}, --end
	]]
}

return MapConfig
