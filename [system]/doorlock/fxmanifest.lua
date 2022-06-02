fx_version "cerulean"
game "gta5"

lua54 "yes"

server_export "updateDoorState"

client_scripts {
    "config.lua",
	"@menu/menu.lua",
	"@key_mapping/mapping.lua",
    "client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}
