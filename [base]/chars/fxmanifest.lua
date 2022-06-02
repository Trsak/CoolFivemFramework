fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
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
	"html/css/css-loader.css",
	"html/css/style.css",
	"html/js/scripts.js",
	"html/img/logo.png",
	"html/img/path.png"
}

exports {
	"preparePlayerPed",
	"startChoosing"
}

server_exports {
	"startCharSelect"
}
