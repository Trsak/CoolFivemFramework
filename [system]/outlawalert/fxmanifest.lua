fx_version "cerulean"
game "gta5"

lua54 "yes"

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

client_scripts {
    "@blips/blips.lua",
    "config.lua",
    "client/main.lua"
}

ui_page {
    "html/main.html"
}

files {
    "html/main.html",
    "html/script.js",
    "html/style.css"
}
