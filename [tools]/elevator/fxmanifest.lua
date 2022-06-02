fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@menu/menu.lua",
    "config.lua",
    "client/main.lua"
}

server_script {
    "config.lua",
    "server/main.lua"
}
