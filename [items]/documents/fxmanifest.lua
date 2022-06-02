fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@blips/blips.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
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
