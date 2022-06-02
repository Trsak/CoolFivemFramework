fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"config.lua",
	"@menu/menu.lua",
	"@font/client.lua",
	"client/*.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/*.lua"
}
