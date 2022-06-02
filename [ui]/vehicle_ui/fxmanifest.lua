fx_version "cerulean"
game "gta5"

lua54 "yes"

export "getStreetName"

client_scripts {
	"config.lua",
	"@key_mapping/mapping.lua",
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
	"html/fonts/AMSANSL.ttf",
	"html/listener.js",
	"html/img/*"
}
