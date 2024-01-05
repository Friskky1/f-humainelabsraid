fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Friskky Developments'
description 'Quick Humaine labs heist'
version '1.5.1'

client_scripts {
	'client/*.lua'
}
server_script {
    'server/*.lua'
}
shared_script {
    'config.lua',
}

escrow_ignore {
    "client/pdalerts.lua",
    "config.lua"
}