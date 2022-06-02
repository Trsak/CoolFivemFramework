fx_version 'bodacious'
game 'gta5'

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua"
}

lua54 "yes"

server_scripts {
	"config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/listener.js"
}
