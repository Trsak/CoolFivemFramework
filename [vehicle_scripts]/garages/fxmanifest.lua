fx_version "cerulean"
game "gta5"
lua54 "yes"

dependency "base_vehicles"

server_export "setVehicleToGarage"
server_export "updateVehicleCurrentGarage"
server_export "createGarage"
server_export "getVehicleGarageData"

client_scripts {
	"@blips/blips.lua",
	"@menu/menu.lua",
	"@key_mapping/mapping.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/listener.js"
}
