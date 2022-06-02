fx_version 'cerulean'
game "gta5"

lua54 "yes"

name 'kgv-blackjack'
description 'Playable Blackjack at the casino, similar to GTAOnline.'
author 'Xinerki - https://github.com/Xinerki/'
url 'https://github.com/Xinerki/kgv-blackjack'

lua54 "yes"

shared_script 'coords.lua'

server_script 'server.lua'

client_script '@font/client.lua'
client_script 'timerbars.lua'
client_script 'client.lua'