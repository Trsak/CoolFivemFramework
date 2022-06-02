fx_version "cerulean"
game "gta5"

lua54 "yes"

export "showPlayerOnMap"
export "spectatePlayer"

server_export "banPlayer"
server_export "banClientForCheating"
server_export "addObjectToPlayerWhitelist"
server_export "setPlayerObjectSkipCheck"
server_export "takePlayerScreenshot"
server_export "sendMessageToAdmins"

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"@key_mapping/mapping.lua",
	"client/main.lua",
	"client/menu.lua",
	"client/atool.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"anticheat-config.lua",
	"server/main.lua",
	"server/anticheat.lua",
	"server/menu.lua",
	"server/report.lua"
}
