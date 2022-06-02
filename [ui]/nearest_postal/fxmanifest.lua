fx_version "cerulean"
game "gta5"

lua54 "yes"

data_file "SCALEFORM_DLC_FILE" "stream/int3232302352.gfx"

files {
	"stream/int3232302352.gfx"
}

client_scripts {
	"config.lua",
	"@blips/blips.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"server/main.lua"
}

server_export "getNearestPostal"
