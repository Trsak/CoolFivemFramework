fx_version "cerulean"
game "common"

lua54 "yes"

name "RageUI"
description "RageUI, and a project specially created to replace the NativeUILua-Reloaded library. This library allows to create menus similar to the one of Grand Theft Auto online."

client_scripts {
    "@key_mapping/mapping.lua",
    "RMenu.lua",
    "menu/RageUI.lua",
    "menu/Menu.lua",
    "menu/MenuController.lua",
    "components/*.lua",
    "menu/elements/*.lua",
    "menu/items/*.lua",
    "menu/panels/*.lua",
    "menu/windows/*.lua"
}
