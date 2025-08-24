Config = {}

-- Framework Configuration
Config.Framework = 'qbcore'  -- 'qbcore', 'esx', 'standalone'
Config.Database = 'oxmysql'   -- 'oxmysql', 'mysql-async'

-- Phone Settings
Config.Keybind = 289          -- F1 key (Default: 289)
Config.Debug = true           -- Enable debug prints
Config.UsePhoneProp = true    -- Spawn phone prop when using
Config.MaxMessages = 100      -- Maximum messages to load per conversation
Config.MaxContacts = 50       -- Maximum contacts per player
Config.MessageMaxLength = 500 -- Maximum characters per message

-- VOIP Integration
Config.VOIP = 'pma-voice'     -- 'pma-voice', 'saltychat', 'tokovoip', 'mumble-voip'

-- Visual Settings
Config.DefaultWallpaper = 'default_wallpaper.png'
Config.Ringtone = 'ringtone.ogg'
Config.PhoneModel = 'prop_phone_01'  -- Phone prop model

-- Animation Settings
Config.Animation = {
    dict = 'cellphone@',
    anim = 'cellphone_text_in',
    duration = -1,
    flag = 50
}

-- Phone Position (relative to screen)
Config.PhonePosition = {
    bottom = '15%',
    right = '8%'
}

-- Apps Configuration
Config.Apps = {
    {
        name = 'phone',
        label = 'Phone',
        icon = '📞',
        color = '#4CAF50',
        enabled = true,
        order = 1
    },
    {
        name = 'messages',
        label = 'Messages',
        icon = '💬',
        color = '#2196F3',
        enabled = true,
        order = 2
    },
    {
        name = 'contacts',
        label = 'Contacts',
        icon = '👥',
        color = '#FF9800',
        enabled = true,
        order = 3
    },
    {
        name = 'bank',
        label = 'Bank',
        icon = '🏦',
        color = '#795548',
        enabled = true,
        order = 4
    },
    {
        name = 'garage',
        label = 'Garage',
        icon = '🚗',
        color = '#9C27B0',
        enabled = true,
        order = 5
    },
    {
        name = 'settings',
        label = 'Settings',
        icon = '⚙️',
        color = '#607D8B',
        enabled = true,
        order = 6
    },
    {
        name = 'camera',
        label = 'Camera',
        icon = '📷',
        color = '#000000',
        enabled = true,
        order = 7
    },
    {
        name = 'gallery',
        label = 'Gallery',
        icon = '🖼️',
        color = '#E91E63',
        enabled = true,
        order = 8
    },
    {
        name = 'notes',
        label = 'Notes',
        icon = '📝',
        color = '#FFD700',
        enabled = true,
        order = 9
    },
    {
        name = 'calculator',
        label = 'Calculator',
        icon = '🧮',
        color = '#FF5722',
        enabled = true,
        order = 10
    }
}

-- Banking Configuration
Config.Banking = {
    enabled = true,
    allowTransfers = true,
    transferCooldown = 5, -- seconds between transfers
    maxTransferAmount = 50000,
    minTransferAmount = 1,
    transactionFee = 0, -- Percentage (0 = no fee)
    showBalance = true,
    showTransactions = true,
    maxTransactionHistory = 20
}

-- Messaging Configuration
Config.Messaging = {
    enabled = true,
    allowImages = false,    -- Enable image messages (requires image hosting)
    allowLocation = true,   -- Enable location sharing
    readReceipts = true,    -- Show read/unread status
    typingIndicator = false, -- Show typing indicator
    deleteMessages = true,  -- Allow message deletion
    editMessages = false,   -- Allow message editing
    messageSound = true     -- Play sound on new message
}

-- Call Configuration
Config.Calling = {
    enabled = true,
    maxCallDuration = 3600, -- Max call duration in seconds (1 hour)
    callHistory = true,     -- Save call history
    busySignal = true,      -- Show busy when player is already in call
    callWaiting = false,    -- Allow call waiting
    voicemail = false,      -- Enable voicemail system
    callSound = true,       -- Play ringtone
    vibration = true        -- Phone vibration effect
}

-- Contacts Configuration
Config.Contacts = {
    enabled = true,
    allowAvatars = false,   -- Enable contact photos
    favoriteContacts = true, -- Allow favorite contacts
    shareContacts = false,   -- Allow sharing contacts
    importContacts = false,  -- Allow importing from other sources
    contactSync = false      -- Sync contacts with other systems
}

-- Garage/Vehicle Configuration
Config.Garage = {
    enabled = true,
    showVehicleStatus = true,    -- Show engine/body condition
    showFuelLevel = true,        -- Show fuel level
    allowRemoteStart = false,    -- Enable remote start
    allowGPSTracking = true,     -- Show vehicle location
    showInsurance = false,       -- Show insurance status
    showPayments = false         -- Show vehicle payments
}

-- Security Settings
Config.Security = {
    enableAntiCheat = true,      -- Basic anti-cheat measures
    phoneCodeRequired = false,   -- Require unlock code
    fingerprintUnlock = true,    -- Fingerprint unlock animation
    faceID = false,              -- Face ID unlock
    autoLock = true,             -- Auto lock after inactivity
    autoLockTime = 30,           -- Auto lock time in seconds
    wipeDataOnFail = false,      -- Wipe data after failed attempts
    maxFailAttempts = 5          -- Max unlock attempts
}

-- Sound Configuration
Config.Sounds = {
    enabled = true,
    ringtones = {
        'ringtone.ogg',
        'ringtone2.ogg',
        'marimba.ogg',
        'apex.ogg',
        'classic.ogg',
        'modern.ogg'
    },
    notificationSounds = {
        'notification.ogg',
        'ding.ogg',
        'chime.ogg',
        'message.ogg',
        'alert.ogg'
    },
    keypadSounds = true,         -- Keypad click sounds
    uiSounds = true,             -- UI interaction sounds
    volume = 0.5                 -- Sound volume (0.0 to 1.0)
}

-- Wallpapers
Config.Wallpapers = {
    'default_wallpaper.png',
    'wallpaper2.png',
    'wallpaper3.png',
    'wallpaper4.png',
    'dark_wallpaper.png',
    'space_wallpaper.png',
    'city_wallpaper.png',
    'nature_wallpaper.png'
}

-- Status Bar Carriers
Config.Carriers = {
    'Verizon',
    'AT&T',
    'T-Mobile',
    'Sprint',
    'Los Santos Mobile',
    'Blaine County Wireless'
}

-- Language Settings
Config.Locale = 'en' -- Available: 'en', 'es', 'fr', 'de', 'pt', 'it'

-- Webhook Configuration (for logging)
Config.Webhooks = {
    enabled = false,
    calls = '',              -- Discord webhook URL for call logs
    messages = '',           -- Discord webhook URL for message logs
    banking = '',            -- Discord webhook URL for banking logs
    general = ''             -- Discord webhook URL for general logs
}