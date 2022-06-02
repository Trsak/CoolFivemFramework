fx_version "cerulean"
game "gta5"

lua54 "yes"

export "getLicenses"
export "hasLicense"


server_export "makeLicenseCard"
server_export "blockLicences"
server_export "unblockLicences"
server_export "addLicenseToChar"
server_export "getCharLicenses"

client_scripts {
	"@blips/blips.lua",
	"@font/client.lua",
	"config.lua",
	"client/main.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/style.css",
	"html/boosttrap.css",
	"html/listener.js"
}
