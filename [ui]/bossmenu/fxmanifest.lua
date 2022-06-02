fx_version "cerulean"
game "gta5"

lua54 "yes"


client_scripts {
	"config.lua",
    "@menu/menu.lua",
	"client/main.lua"
}

shared_scripts {
	"@modules/utils.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
    "@data/shared/functions.lua",
	"server_config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/boosttrap.css",
	"html/listener.js",
	"html/vpici.png"
}


export "openBossMenu"
export "openApplicationMenu"