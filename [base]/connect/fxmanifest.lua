fx_version "cerulean"
game "gta5"

lua54 "yes"

server_only "yes"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}

server_export "addNewBan"