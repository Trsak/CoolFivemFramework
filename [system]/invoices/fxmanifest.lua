fx_version "cerulean"
game "gta5"

lua54 "yes"

export "giveInvoice"
server_export "getInvoiceList"
server_export "getSenderInvoiceList"
server_export "setInvoicePaid"
server_export "getInvoiceData"

client_scripts {
    "@data/shared/functions.lua",
	"@menu/menu.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"@oxmysql/lib/MySQL.lua",
	"server/main.lua",
}