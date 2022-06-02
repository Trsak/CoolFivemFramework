fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@menu/menu.lua",
	"@blips/blips.lua",
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
	"html/fonts/gs.ttf",
	"html/listener.js"
}

export "getProductPrice"

server_export "getShops"
server_export "buyItem"
server_export "generateSerialNumber"
server_export "addItemToShop"
server_export "createSpecialShop"
