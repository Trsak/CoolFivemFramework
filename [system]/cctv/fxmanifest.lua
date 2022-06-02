fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
    "server/main.lua",
    "config.lua"
}

client_scripts {
    "@key_mapping/mapping.lua",
    "config.lua",
    "@menu/menu.lua",
    "client/main.lua"
}
