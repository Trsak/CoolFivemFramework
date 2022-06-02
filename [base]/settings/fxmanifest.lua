fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@key_mapping/mapping.lua",
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"server/main.lua"
}

export "changeSetting"
export "getSettingValue"
