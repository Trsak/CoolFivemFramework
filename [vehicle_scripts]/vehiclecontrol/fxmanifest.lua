fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "@menu/menu.lua",
    "client/main.lua"
}
server_scripts {
    "server/main.lua"
}

export "toggleDoor"
export "toggleWindow"
export "toggleHood"
