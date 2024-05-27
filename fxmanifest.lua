fx_version 'adamant'

game 'gta5'

name 'sasy-death'
author 'Sasy'

lua54 'yes'

version '1.0'

client_scripts {
    'client/**.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**.lua'
}

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}

escrow_ignore {
    'config.lua',
}
