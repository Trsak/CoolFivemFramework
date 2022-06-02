fx_version 'cerulean'
games { 'gta5' }

author 'Slayer'
description 'Insurance Laptop'
version '0.0.1'

ui_page 'nui/index.html'

files {
    'nui/*.html',
    "nui/js/*.js",
    "nui/css/*.css",
    "nui/img/*.png",
    "nui/img/*.jpg",
    "cfg.json"
}

shared_scripts {
    'config.lua',
    'modules/utils.lua',
    'modules/vector3.lua'
}


client_scripts {
    'client/main.lua'
}

server_script {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/function.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_billing'
}

exports {
}