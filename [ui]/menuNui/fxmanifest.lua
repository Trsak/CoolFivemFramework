game "gta5"
fx_version "cerulean"
lua54 "yes"
version '0.0.1'

client_scripts {
	'client/wrapper.lua',
	'client/main.lua'
}

shared_scripts {
	"@modules/utils.lua"
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/klavika.otf'
}
