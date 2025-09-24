fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'rs_hud'
description 'Advanced ESX HUD (NUI)'
author 'dein-name'
version '1.0.0'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/styles.css',
  'html/app.js',
  'html/libs/jquery-3.7.1.min.js',
  'html/libs/gsap.min.js'
}

shared_scripts {
  'config.lua'
}

client_scripts {
  '@es_extended/imports.lua',
  'client/client.lua'
}

server_scripts {
  'server/server.lua'
}
