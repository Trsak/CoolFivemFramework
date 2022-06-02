fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "@server_vehicle/shared/vehicles.lua",
    "@menu/menu.lua",
    "@data/shared/functions.lua",
    "config.lua",
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}

export "openMechanicMenu"
