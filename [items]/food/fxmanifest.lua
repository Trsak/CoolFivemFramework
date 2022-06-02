fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua",
}


server_scripts {
	"config.lua",
	"server/main.lua",
}

export "getItem"
export "getEatables"
export "getDrinkables"
server_export "getItem"
server_export "giveItem"
server_export "isPlayerEating"