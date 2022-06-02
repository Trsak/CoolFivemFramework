fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

client_scripts {
    "config.lua",
    "client/main.lua"
}

server_export "getPlayerData"
server_export "getVipLevel"
server_export "getQueQuePoints"

export "getVipLevel"
