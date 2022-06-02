fx_version "cerulean"
game "gta5"

lua54 "yes"

export "registerWeapon"
server_export "registerWeapon"

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
}
