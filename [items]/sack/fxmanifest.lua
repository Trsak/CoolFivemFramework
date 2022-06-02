fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {"@menu/menu.lua", "config.lua", "client/main.lua"}

server_script "server/main.lua"

ui_page "html/index.html"

file "html/index.html"

exports {
    "takeOffSack",
    "takeOnSack"
}