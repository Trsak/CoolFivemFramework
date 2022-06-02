fx_version 'bodacious'
game 'gta5'

author 'Hellslicer'
description 'This resource allows you to integrate your own radios in place of the original radios'
version '2.0.0'

-- Example custom radios
supersede_radio 'RADIO_21_DLC_XM17' { url = 'http://gtatime.duckdns.org:8000/airtime_256', volume = 0.35, name = 'Gans Radio Los Santos by Weazel' }

files {
    'index.html'
}

ui_page 'index.html'

client_scripts {
    'data.js',
    'client.js'
}
