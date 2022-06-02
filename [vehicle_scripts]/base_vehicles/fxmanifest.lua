fx_version "cerulean"
game "gta5"

lua54 "yes"

server_export "getVehicles"
server_export "getVehicle"
server_export "doesVehicleExist"
server_export "addVehicle"
server_export "updateVehicle"

server_export "getOwnedVehicles"
server_export "getVehicleCurrentGarage"
server_export "getAvailableVehiclesFromGarage"
server_export "updateVehicleCurrentGarage"
server_export "checkCharVehicleCredibility"
server_export "changeVehicleBlockStatus"
server_export "getVehicleBlockStatus"
server_export "changeVehicleOwner"
server_export "updateVehiclePlate"
server_export "getJobVehicle"
server_export "updateVehicleJobData"
server_export "createVehicle"
server_export "removeVehicle"
server_export "removeVehicleByActualPlate"
server_export "isStateJob"

export "getVehicleNameByHash"
export "SetVehicleProperties"
export "GetVehicleProperties"
export "spawnVehicle"

client_scripts {
	"@menu/menu.lua",
	"config.lua",
	"addon_vehicles.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}