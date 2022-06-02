fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "config.lua",
    "shared/*.lua",
    "client/*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server_config.lua",
    "shared/*.lua",
    "server/*.lua"
}

server_export "askForRyan"