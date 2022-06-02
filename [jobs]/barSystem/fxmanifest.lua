fx_version 'cerulean'
games { 'gta5' }

author 'Slayer'
description 'Bar System'
lua54 'yes'
version '0.0.1'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    "nui/js/*.js",
    "nui/lib/*.sh",
    "nui/lib/*.js",
    "nui/extras/*.js",
    "nui/css/*.css",
    "nui/img/*.png",
    "@inventory/ui/items/*.png"
}

shared_scripts {
    '@modules/utils.lua',
    'config.lua'
}

client_scripts {
    "@menu/menu.lua",
    "@key_mapping/mapping.lua",
    'client/main.lua',
    'client/menus.lua'
}

server_script {
    "@oxmysql/lib/MySQL.lua",
    'server/main.lua'
}

export 'makeMenu'
server_export 'getConsumable'
server_export 'getConsumables'