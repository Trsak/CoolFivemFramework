fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
	"@menu/menu.lua",
	"@font/client.lua",
	"@key_mapping/mapping.lua",
	"client/main.lua",
	"client/binds.lua",
	"client/drops.lua",
	"client/shops.lua",
	"client/player.lua",
	"client/storages.lua",
	"client/trunk.lua",
	"client/magazines.lua",
	"client/weaponcomponents.lua",
	"client/casino.lua",
	"client/crafting.lua"
}

shared_scripts {
	'@modules/utils.lua',
	"config.lua",
	"crafting.lua",
	"weapons.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/*.lua",
	"server_config.lua",
}

files {
	"ui/inventory.html",
	"ui/fonts/*",
	"ui/css/style.css",
	"ui/js/scripts.js",
	"ui/img/bullet.png",
	--items
	"ui/items/*.png",
	"ui/items/plates/*.png"
}

ui_page {
	"ui/inventory.html"
}

export "getWeaponAmmo"
export "getCurrentCash"
export "getItem"
export "getMobiles"
export "getSimCards"
export "getActiveMobile"
export "checkPlayerMobile"
export "setupPlayerWeapons"
export "getWeaponLabel"
export "getActiveWeapons"
export "getUsableItems"
export "checkCarKey"
export "checkDoorKey"
export "checkTransmitter"
export "openShop"
export "openTrunk"
export "openGlovebox"
export "closeInventory"
export "tryToUseItem"
export "openInventory"
export "disableInventory"
export "getWeaponFromHash"
export "reload_weapon"
export "getPlayerItems"
export "getCasinoChipsTotalValue"
export "setBindOverwritten"
export "getComponentNameByHash"

server_export "openStorage"
server_export "clearPlayerInventory"
server_export "getPlayerInventory"
server_export "getPlayerCurrentWeight"
server_export "getPlayerMaxWeight"
server_export "getPlayerItemCount"
server_export "checkPlayerItem"
server_export "addPlayerItem"
server_export "forceAddPlayerItem"
server_export "removePlayerItem"
server_export "removeMultiplePlayerItems"
server_export "savePlayerInventory"
server_export "getItem"
server_export "getItems"
server_export "itemDropped"
server_export "updateItemData"
server_export "updateItemDataBySlot"
server_export "addCasinoChips"
server_export "removeCasinoChips"
server_export "getCasinoChips"
server_export "getCasinoChipsTotalValue"
server_export "getCasinoChipsValues"
server_export "removeCasinoChipsByValue"
server_export "getAreItemsLoaded"
server_export "changeVehicleTrunkToNewPlate"
