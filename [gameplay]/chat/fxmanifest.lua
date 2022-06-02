-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 "yes"

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Provides baseline chat functionality using a NUI-based interface.'
repository 'https://github.com/citizenfx/cfx-server-data'

ui_page 'dist/ui.html'

client_script 'cl_chat.lua'
server_script 'sv_chat.lua'

files {
  'dist/ui.html',
  'dist/index.css',
  'html/vendor/*.css',
  'html/vendor/fonts/*.woff2',
}

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
  'yarn',
  'webpack'
}

export "addMessage"
server_export "displayMeDoDoc"

webpack_config 'webpack.config.js'
