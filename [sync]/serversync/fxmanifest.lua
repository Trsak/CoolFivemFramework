fx_version "cerulean"
game "gta5"

lua54 "yes"

client_scripts {
    "ss_shared_functions.lua",
    "config/ServerSync.lua",
    "ss_cli_traffic_crowd.lua",
    "ss_cli_weather.lua",
    "ss_cli_time.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "ss_shared_functions.lua",
    "config/ServerSync.lua",
    "ss_srv_weather.lua",
    "ss_srv_time.lua"
}
