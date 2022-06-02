fx_version "cerulean"
game "gta5"

lua54 "yes"

export "getClosestPlayer"
export "getClosestPlayersInDistance"
export "reverseArray"
server_export "isDev"

client_scripts {
    "@key_mapping/mapping.lua",
    "config.lua",
    "client/main.lua",
    "client/death.lua",
    "client/tackle.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua",
    "server/tackle.lua"
}
