fx_version "cerulean"
game "gta5"

lua54 "yes"

shared_scripts {
    "config.lua"
}

client_scripts {
    "@menu/menu.lua",
    "@blips/blips.lua",
    "client.lua"
}

server_script {
    "server.lua"
}

export "getIsInCasino"