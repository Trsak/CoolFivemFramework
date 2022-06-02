fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@blips/blips.lua",
	"config.lua",
	"@menu/menu.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}
