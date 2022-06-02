fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua"
}
