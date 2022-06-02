game "gta5"
fx_version "cerulean"

lua54 "yes"

client_script {"@key_mapping/mapping.lua", "@menu/menu.lua", "client/*.lua"}
shared_scripts {"config.lua", '@inventory/weapons.lua'}

export 'loadAmmoIntoMagazine'
server_script "server.lua"

server_export "hasWeaponFireMods"
