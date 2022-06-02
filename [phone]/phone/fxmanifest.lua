fx_version 'cerulean'
game 'gta5'

description 'QB-Phone rewrite by me'
version '1.1.5'
lua54 'yes'
ui_page 'html/index.html'
provide "mysql-async"

client_scripts {
    "@menu/menu.lua",
    "@font/client.lua",
    '@key_mapping/mapping.lua',
    'client/*.lua'
}

shared_scripts {
    '@modules/utils.lua',
    'config.lua'
}

server_script {
    "@oxmysql/lib/MySQL.lua",
    'server/*.lua'
}

files {
    'html/*.html',
    'html/js/*.js',
    'html/img/**/*.png',
    'html/css/*.css',
    'html/fonts/*.ttf',
    'html/fonts/*.otf',
    'html/fonts/*.woff'
}

export "ActivateMobile"
export "ActiveSim"
export "InPhone"
export "mobileMenu"

server_export "getAllPhones"
server_export "savePlayerMobile"
server_export "sentEmail"
server_export "create"