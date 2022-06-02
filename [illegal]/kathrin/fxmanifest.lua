fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_script {
    "config.lua",
    "@modules/utils.lua"
}
-- What to run
client_scripts {
    "@menu/menu.lua",
    "client/client.lua"
}

server_script {
    "@data/shared/functions.lua",
    "server_config.lua",
    "server/server.lua"
}
