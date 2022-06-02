fx_version 'cerulean'
game 'gta5'

description 'Player Near coords'
version '0.0.1'
lua54 'yes'

client_scripts {
    'client.lua'
}

shared_scripts {
    '@modules/utils.lua'
}
server_scripts {
    'server.lua'
}

server_export "add_event"