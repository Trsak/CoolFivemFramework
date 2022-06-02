fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "@blips/blips.lua",
    "@menu/menu.lua",
    "config.lua",
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/css/*",
    "html/js/*",
    "html/img/*"
}

server_export "getPlayerAccesibleAccounts"
server_export "getJobAccesibleAccounts"
server_export "payFromAccountToAccount"
server_export "payFromAccount"
server_export "sendToAccount"
server_export "doesAccountExist"
