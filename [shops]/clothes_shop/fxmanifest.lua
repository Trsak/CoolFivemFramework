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

export "openClothesMenu"
export "setSpecialOutfit"
