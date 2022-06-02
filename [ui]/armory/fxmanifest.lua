fx_version "cerulean"
game "gta5"

lua54 "yes"

export "openArmory"

client_scripts {
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"server_config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/fonts/kk.ttf",
	"html/listener.js",
	"@inventory/ui/items/*.png"
}
