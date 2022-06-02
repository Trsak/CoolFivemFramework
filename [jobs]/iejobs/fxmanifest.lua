fx_version 'cerulean'
game 'gta5'

author 'Slayer'
description 'Export / Import Jobs'
version '0.0.1'
lua54 "yes"

ui_page 'html/index.html'

files {
    'html/index.html',
    "html/*.js",
    "html/styles.css",
    "html/img/*.png"
}

client_scripts {
    'client/main.lua',
    'client/menu.lua',
    'client/work.lua'
}

shared_scripts {
    '@modules/utils.lua',
    '@modules/vector3.lua'
}


server_script {
    "@oxmysql/lib/MySQL.lua",
    'server/function.lua',
    'server/main.lua'
}