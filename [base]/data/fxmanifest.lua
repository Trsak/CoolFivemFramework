fx_version "cerulean"
game "gta5"

lua54 "yes"

export "getUserVar"
export "getCharVar"
export "updateCharCH"
export "saveChar"
export "isCharLoaded"
export "isUserLoaded"
export "getVehicleActualPlateNumber"
export "setVehicleActualPlateText"
export "getVehicleVin"

server_export "removeUserData"
server_export "updateCharVar"
server_export "updateUserVar"
server_export "getUserVar"
server_export "getCharVar"
server_export "getCharNameById"
server_export "newConnectedUser"
server_export "getUsers"
server_export "getUsersBaseData"
server_export "getUser"
server_export "saveChar"
server_export "getVehicleActualPlateNumber"
server_export "getVehicleVin"
server_export "getCachedPlayerIdentifier"
server_export "getUserByIdentifier"
server_export "getSteamIdentifier"
server_export "setVehicleActualPlateText"
server_export "getUsersBlipData"
server_export "getUserByCharId"
server_export "countEmployees"

export "getFormattedCurrency"
server_export "getFormattedCurrency"

shared_scripts {
	"config.lua",
	"shared/functions.lua"
}

client_scripts {
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua"
}
