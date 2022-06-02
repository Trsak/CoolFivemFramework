fx_version "cerulean"
game "gta5"

lua54 "yes"

server_export "addFine"
server_export "markFineAsPaid"
server_export "getFineList"
server_export "getFineData"

client_scripts {
	"@menu/menu.lua",
	"@data/shared/functions.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua"
}
