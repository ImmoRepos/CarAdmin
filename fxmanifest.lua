fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Leon Kappes (Elsinar) <info@elsetech.cloud>'
description 'Adminmenu for Carrelated options'
version "1.0.0"

client_scripts {
    'client/**.lua',
    'client/menuapi.lua',
}

server_scripts {
    'server/**.lua'
}

shared_script 'config.lua'