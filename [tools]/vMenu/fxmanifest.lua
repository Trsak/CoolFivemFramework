fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@modules/utils.lua'
}

client_scripts {
    "@menu/menu.lua",
    'main.lua'
}

export "setvMenuPed"
export "getvMenuPeds"
export "getvMenuPedNames"
export "hasvMenuPeds"