fx_version "bodacious" -- NEMĚNIT NA NOVĚJŠÍ!
game "gta5"

lua54 "yes"

client_script "client/main.lua"

server_script "server/main.lua"

ui_page("client/html/index.html")

files(
    {
        "client/html/index.html",
        "client/html/howler.js",
        "client/html/script.js"
    }
)
