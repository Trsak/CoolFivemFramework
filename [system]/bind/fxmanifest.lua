fx_version "cerulean"
game "gta5"

lua54 "yes"

ui_page "nui/binding.html"

files {
    "nui/binding.html",
    "nui/binding.css",
    "nui/btns.min.css",
    "nui/binding.js"
}

client_scripts {
    "@menu/menu.lua",
    "client.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server.lua"
}

export "openBinding"
export "addBind"