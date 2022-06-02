fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@key_mapping/mapping.lua",
	"@menu/menu.lua",
	"@blips/blips.lua",
	"config.lua",
	"client/*.lua"
}

shared_scripts {
	'@modules/utils.lua'
}

server_scripts {
	"config.lua",
	"server/*.lua"
}
