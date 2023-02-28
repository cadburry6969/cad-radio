fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'Cadburry'
description 'Radio System for SOULCITY'

shared_scripts {
    "config.lua"
}
client_script "client.lua"
server_script "server.lua"

files {
    'nui/*',
}
ui_page 'nui/ui.html'
