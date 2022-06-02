fx_version "cerulean"
game "gta5"

lua54 "yes"

server_export "createOrder"
server_export "getOrders"
server_export "getOrdersInShop"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}
