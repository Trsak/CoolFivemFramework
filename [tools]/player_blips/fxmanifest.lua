fx_version 'cerulean'
games { 'gta5' }

author 'Slayer'
description 'server.cz | Blips'
lua54 'yes'
version '1.0'

client_scripts {
    "@key_mapping/mapping.lua",
    'client/client.lua'
}

shared_script {
    '@modules/utils.lua',
    'config.lua'
}

server_scripts {
    'server/server.lua'
}

export 'hideBlip'
export 'stopBlip'
export 'removeBlip'
export 'addGPS'

server_export 'addAdmin'
server_export 'addVeh'
server_export 'addPlayer'