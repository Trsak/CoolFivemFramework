fx_version "cerulean"
game "gta5"

lua54 "yes"

dependencies {
    "PolyZone"
}

ui_page "html/index.html"

client_scripts {
    "@PolyZone/client.lua",
    "@PolyZone/BoxZone.lua",
    "@PolyZone/EntityZone.lua",
    "@PolyZone/CircleZone.lua",
    "@PolyZone/ComboZone.lua",
    "@key_mapping/mapping.lua",
    "config.lua",
    "client/main.lua"
}

files {
    "html/index.html",
    "html/css/*.css",
    "html/fonts/*",
    "html/js/script.js"
}
