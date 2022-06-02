fx_version 'cerulean'
game 'gta5'

author 'JayMontana36'
description 'Remade Plane Smoke Script For OneSync'
version '1.1-JM36_BETA-1.2'
lua54 'yes'


client_scripts {
    "@key_mapping/mapping.lua",
    'FSRP_PlaneSmoke_cl.lua'
}
shared_script '@modules/utils.lua'
server_script 'FSRP_PlaneSmoke_sv.lua'
