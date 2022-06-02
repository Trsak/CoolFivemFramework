fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"config.lua",
    '@modules/utils.lua',
    "@key_mapping/mapping.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
    '@modules/utils.lua',
	"server/main.lua",
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/listener.js"
}
