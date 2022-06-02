fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"server/main.lua"
}

ui_page("html/index.html")

files {
	"html/index.html",
	"html/css/style.css",
	"html/js/script.js"
}

export "changeSkill"
