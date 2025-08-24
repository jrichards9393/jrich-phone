fx_version 'cerulean'
game 'gta5'

author 'jrich - Enhanced Quasar Style'
description 'Enhanced Quasar-style iPhone interface for QBCore FiveM - jrich-phone v2.0'
version '2.0.0'

-- NUI Configuration
ui_page 'html/index.html'

-- Client Files
files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/sounds/*.ogg'
}

-- Client Scripts
client_scripts {
    'client/main.lua'  -- ← UPDATED PATH
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'  -- ← UPDATED PATH
}

-- Shared Scripts
shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',  -- ← UPDATED PATH
    'shared/locale.lua',  -- ← NEW FILE
    'shared/utils.lua'    -- ← NEW FILE
}

-- Dependencies
dependencies {
    'ox_lib',
    'qb-core',
    'oxmysql'
}

lua54 'yes'