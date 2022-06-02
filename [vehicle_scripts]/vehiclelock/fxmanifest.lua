fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@key_mapping/mapping.lua",
	"client/main.lua"
}

server_scripts {
	"server/main.lua"
}

export "isVehicleLocked"
export "lockVehicle"
export "unlockVehicle"
