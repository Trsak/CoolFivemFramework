fx_version "cerulean"
game "gta5"

lua54 "yes"

server_only "yes"
server_scripts {
    "server/main.lua",
    "server/webhooks.lua",
}

server_export "sendToDiscord"
