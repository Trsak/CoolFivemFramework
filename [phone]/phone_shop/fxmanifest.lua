fx_version 'cerulean'
game 'gta5'

description 'Phone Shop by me'
version '0.0.5'
lua54 'yes'

ui_page 'html/index.html'

client_scripts {
    "@menu/menu.lua",
    "@font/client.lua",
    '@key_mapping/mapping.lua',
    'client/*.lua'
}

shared_scripts {
    '@modules/utils.lua',
    '@phone/config.lua',
    'config.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/*.lua'
}

files {
    'html/*.html',
    'html/js/*.js',
    'html/css/*.css',
    'html/img/*.jpg',
    'html/img/*.png',
}