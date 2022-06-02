fx_version "cerulean"
game "gta5"

lua54 "yes"

author "NewEdit#8679"

client_scripts {
	"@menu/menu.lua",
	"@blips/blips.lua",
	"@PolyZone/client.lua",
	"@PolyZone/BoxZone.lua",
	"config.lua",
	"client/main.lua"
}
server_scripts {
	"@server_vehicle/shared/vehicles.lua",
	"config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/images/vehicles/*.png",
	"html/images/base/*.png",
	"html/build/*.css",
	"html/js/*"
}
