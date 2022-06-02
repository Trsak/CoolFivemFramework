fx_version "cerulean"
game "gta5"

lua54 "yes"

ui_page "html/index.html"

client_scripts {"client/*.lua"}

files {"html/index.html", "html/css/style.css", "html/js/script.js"}

export "startProgressBar"
export "hasProgressBar"
export "cancelProgressBar"