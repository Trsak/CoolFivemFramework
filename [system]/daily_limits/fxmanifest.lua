fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/*.lua"
}

server_export "checkIfIsOverLimit"
server_export "addLimitCount"
