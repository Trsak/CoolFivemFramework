fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "@blips/blips.lua",
    "@key_mapping/mapping.lua",
    "config.lua",
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

server_export "dutySecret"
server_export "add"
server_export "remove"
server_export "activateFlash"
