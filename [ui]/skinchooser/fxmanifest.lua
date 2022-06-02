fx_version "bodacious"
game "gta5"

lua54 "yes"

client_scripts {
    "@menu/menu.lua",
    "config.lua",
    "client/main.lua",
    "client/tattoos.lua",
    "client/clothing.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "tattooList.lua",
    "server/tattoos.lua",
    "server/clothing.lua"
}

export "getPlayerSex"
export "loadSavedOutfit"
export "openSkinMenu"
export "useClothesItem"

export "setPlayerModel"
export "setPlayerOutfit"
export "getPlayerOutfit"

export "openClothingMenu"

export "getCurrentTattoos"
export "getTattosList"
export "getTattosListByZone"
