fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@blips/blips.lua",
	"client/main.lua",
	"config.lua"
}

server_scripts {
	"server/*.lua"
}

exports {
	"GetFuel",
	"SetFuel"
}
