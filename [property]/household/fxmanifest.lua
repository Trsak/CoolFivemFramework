fx_version "cerulean"
game "gta5"

lua54 "yes"

server_export "createHouse"
server_export "getHouseDetails"

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
