--!strict

local ServerStorage = game:GetService("ServerStorage")
local Cmdr = require(ServerStorage.ServerPackages.cmdr)

local cmdrConfig = ServerStorage.CMDRConfig

Cmdr:RegisterHooksIn(cmdrConfig.Hooks)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(cmdrConfig.CustomCommands)

return {}
