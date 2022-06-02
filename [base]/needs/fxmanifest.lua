fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"config.lua",
	"client/*.lua"
}

server_scripts {
	"server/main.lua"
}

export "setNeed"
export "changeNeed"
export "getNeed"
