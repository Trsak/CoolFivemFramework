fx_version "cerulean"
game "gta5"

lua54 "yes"

export "cuff"
export "openTrunk"

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
	"html/css/*",
	"html/js/*"
}
