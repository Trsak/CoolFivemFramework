fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
	"config.lua",
	"server/main.lua"
}

client_scripts {
	"config.lua",
	"client/main.lua"
}

export "getPlayerInstance"

server_export "getInstances"
server_export "createInstanceIfNotExists"
server_export "getPlayerInstance"
server_export "playerJoinInstance"
server_export "playerQuitInstance"
server_export "getInstancePostalCode"
