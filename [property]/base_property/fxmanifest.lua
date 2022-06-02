fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@blips/blips.lua",
	"@menu/menu.lua",
	"@key_mapping/mapping.lua",
    "@data/shared/functions.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}

server_export "getPropertyData"
