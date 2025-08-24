local QBCore = exports['qb-core']:GetCoreObject()

-- Verify QBCore
if not QBCore then
    Utils.debugPrint('ERROR: QBCore not found! Ensure qb-core is running.')
    return
end

Utils.debugPrint('Phone server loaded successfully')

-- Player cache
local playerCache = {}

-- Helper Functions
local function GetPlayer(src)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then
        Utils.debugPrint('ERROR: Player not found for source: ' .. src)
    end
    return player
end

local function GetPlayerByPhone(number)
    local players = QBCore.Functions.GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.charinfo.phone == tostring(number) then
            return player, src
        end
    end
    return nil, nil
end

local function GetPlayerByCitizenId(citizenid)
    local players = QBCore.Functions.GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.citizenid == citizenid then
            return player, src
        end
    end
    return nil, nil
end

-- Database wrapper
local function ExecuteQuery(query, params, callback)
    if GetResourceState('oxmysql') ~= 'started' then
        Utils.debugPrint('ERROR: oxmysql not found!')
        if callback then callback(false) end
        return false
    end
    
    if callback then
        exports.oxmysql:execute(query, params, callback)
    else
        return exports.oxmysql:execute_scalar(query, params)
    end
end

-- Initialize database tables on resource start
local function InitializeDatabase()
    Utils.debugPrint('Initializing database tables...')
    
    -- Check if tables exist, create if they don't
    local queries = {
        [[CREATE TABLE IF NOT EXISTS `jrich_phone_contacts` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `name` varchar(255) NOT NULL,
            `number` varchar(20) NOT NULL,
            `avatar` varchar(255) DEFAULT NULL,
            `favorite` tinyint(1) DEFAULT 0,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_citizenid` (`citizenid`),
            KEY `idx_number` (`number`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
        
        [[CREATE TABLE IF NOT EXISTS `jrich_phone_messages` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `sender_number` varchar(20) NOT NULL,
            `receiver_number` varchar(20) NOT NULL,
            `message` text NOT NULL,
            `read_status` tinyint(1) DEFAULT 0,
            `message_type` enum('text','image','location') DEFAULT 'text',
            `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_sender` (`sender_number`),
            KEY `idx_receiver` (`receiver_number`),
            KEY `idx_timestamp` (`timestamp`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
        
        [[CREATE TABLE IF NOT EXISTS `jrich_phone_call_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `caller` varchar(20) NOT NULL,
            `receiver` varchar(20) NOT NULL,
            `status` enum('initiated','answered','missed','ended','busy') NOT NULL,
            `duration` int(11) DEFAULT 0,
            `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_caller` (`caller`),
            KEY `idx_receiver` (`receiver`),
            KEY `idx_timestamp` (`timestamp`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
        
        [[CREATE TABLE IF NOT EXISTS `jrich_phone_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `amount` int(11) NOT NULL,
            `type` enum('deposit','withdraw','transfer_in','transfer_out','payment') NOT NULL,
            `reason` varchar(255) NOT NULL,
            `target` varchar(50) DEFAULT NULL,
            `reference` varchar(100) DEFAULT NULL,
            `timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_citizenid` (`citizenid`),
            KEY `idx_timestamp` (`timestamp`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]],
        
        [[CREATE TABLE IF NOT EXISTS `jrich_phone_settings` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `setting_key` varchar(100) NOT NULL,
            `setting_value` text,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_citizen_setting` (`citizenid`, `setting_key`),
            KEY `idx_citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]]
    }
    
    for _, query in ipairs(queries) do
        ExecuteQuery(query, {}, function(result)
            if result then
                Utils.debugPrint('Database table initialized successfully')
            else
                Utils.debugPrint('WARNING: Failed to initialize database table')
            end
        end)
    end
end

-- Cache player data
local function CachePlayerData(src)
    local player = GetPlayer(src)
    if not player then return end
    
    playerCache[src] = {
        citizenid = player.PlayerData.citizenid,
        phone = player.PlayerData.charinfo.phone,
        firstname = player.PlayerData.charinfo.firstname,
        lastname = player.PlayerData.charinfo.lastname,
        lastActivity = os.time()
    }
end

-- Server Events
RegisterServerEvent('jrich-phone:playerLoaded')
AddEventHandler('jrich-phone:playerLoaded', function()
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    CachePlayerData(src)
    Utils.debugPrint('Player loaded: ' .. player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname)
    
    -- Load player settings
    TriggerEvent('jrich-phone:loadSettings', src)
    
    -- Send welcome notification
    TriggerClientEvent('jrich-phone:notification', src, _('phone_unlocked'), _('phone') .. ' ' .. _('success'), 'success')
end)

RegisterServerEvent('jrich-phone:loadSettings')
AddEventHandler('jrich-phone:loadSettings', function()
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    
    ExecuteQuery('SELECT setting_key, setting_value FROM jrich_phone_settings WHERE citizenid = ?', {citizenid}, function(settings)
        local settingsData = {}
        if settings then
            for _, setting in pairs(settings) do
                settingsData[setting.setting_key] = setting.setting_value
            end
        end
        
        -- Set defaults if not exists
        if not settingsData.wallpaper then
            settingsData.wallpaper = Config.DefaultWallpaper
        end
        if not settingsData.ringtone then
            settingsData.ringtone = Config.Ringtone
        end
        
        TriggerClientEvent('jrich-phone:updateSettings', src, settingsData)
    end)
end)

-- Call handling
RegisterServerEvent('jrich-phone:call')
AddEventHandler('jrich-phone:call', function(number)
    local src = source
    local caller = GetPlayer(src)
    if not caller then return end
    
    if not Utils.validatePhoneNumber(number) then
        Utils.debugPrint('Invalid phone number: ' .. tostring(number))
        TriggerClientEvent('jrich-phone:notification', src, _('call_failed'), _('invalid_number'), 'error')
        return
    end
    
    local target, targetSrc = GetPlayerByPhone(number)
    if target and targetSrc then
        local callerName = caller.PlayerData.charinfo.firstname .. ' ' .. caller.PlayerData.charinfo.lastname
        local callerNumber = caller.PlayerData.charinfo.phone
        
        Utils.debugPrint('Call from ' .. callerName .. ' (' .. callerNumber .. ') to ' .. number)
        
        -- Log call attempt
        ExecuteQuery('INSERT INTO jrich_phone_call_logs (caller, receiver, status, timestamp) VALUES (?, ?, ?, NOW())', {
            callerNumber, number, 'initiated'
        }, function(result)
            if result then
                Utils.debugPrint('Call logged with ID: ' .. result.insertId)
            end
        end)
        
        -- Notify both parties
        TriggerClientEvent('jrich-phone:incomingCall', targetSrc, callerNumber, callerName)
        TriggerClientEvent('jrich-phone:notification', src, _('calling'), target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname, 'info')
    else
        Utils.debugPrint('Call failed: No player found with number ' .. number)
        TriggerClientEvent('jrich-phone:notification', src, _('call_failed'), _('recipient_not_found'), 'error')
    end
end)

RegisterServerEvent('jrich-phone:answerCall')
AddEventHandler('jrich-phone:answerCall', function(callerNumber)
    local src = source
    local receiver = GetPlayer(src)
    if not receiver then return end
    
    local caller, callerSrc = GetPlayerByPhone(callerNumber)
    if caller and callerSrc then
        Utils.debugPrint('Call answered between ' .. callerNumber .. ' and ' .. receiver.PlayerData.charinfo.phone)
        
        -- Update call log
        ExecuteQuery('UPDATE jrich_phone_call_logs SET status = ? WHERE caller = ? AND receiver = ? AND status = ? ORDER BY timestamp DESC LIMIT 1', {
            'answered', callerNumber, receiver.PlayerData.charinfo.phone, 'initiated'
        })
        
        -- Notify both parties
        TriggerClientEvent('jrich-phone:notification', callerSrc, _('app_phone'), _('call_answered'), 'success')
        TriggerClientEvent('jrich-phone:notification', src, _('app_phone'), _('call_connected'), 'success')
    end
end)

RegisterServerEvent('jrich-phone:endCall')
AddEventHandler('jrich-phone:endCall', function(otherNumber)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local other, otherSrc = GetPlayerByPhone(otherNumber)
    if other and otherSrc then
        Utils.debugPrint('Call ended between ' .. player.PlayerData.charinfo.phone .. ' and ' .. otherNumber)
        
        -- Update call log with duration
        ExecuteQuery('UPDATE jrich_phone_call_logs SET status = ?, duration = TIMESTAMPDIFF(SECOND, timestamp, NOW()) WHERE (caller = ? AND receiver = ?) OR (caller = ? AND receiver = ?) AND status = ? ORDER BY timestamp DESC LIMIT 1', {
            'ended', player.PlayerData.charinfo.phone, otherNumber, otherNumber, player.PlayerData.charinfo.phone, 'answered'
        })
        
        -- Notify both parties
        TriggerClientEvent('jrich-phone:callEnded', src)
        TriggerClientEvent('jrich-phone:callEnded', otherSrc)
    end
end)

-- Message handling
RegisterServerEvent('jrich-phone:sendMessage')
AddEventHandler('jrich-phone:sendMessage', function(receiver, message)
    local src = source
    local sender = GetPlayer(src)
    if not sender then return end
    
    if not Utils.validatePhoneNumber(receiver) then
        TriggerClientEvent('jrich-phone:notification', src, _('message_failed'), _('invalid_number'), 'error')
        return
    end
    
    message = Utils.sanitizeString(message)
    
    if not message or string.len(message) == 0 then
        TriggerClientEvent('jrich-phone:notification', src, _('message_failed'), _('message_empty'), 'error')
        return
    end
    
    if string.len(message) > Config.MessageMaxLength then
        TriggerClientEvent('jrich-phone:notification', src, _('message_failed'), _('message_too_long'), 'error')
        return
    end
    
    local senderNumber = sender.PlayerData.charinfo.phone
    local senderName = sender.PlayerData.charinfo.firstname .. ' ' .. sender.PlayerData.charinfo.lastname
    
    -- Save message to database
    ExecuteQuery('INSERT INTO jrich_phone_messages (sender_number, receiver_number, message, timestamp) VALUES (?, ?, ?, NOW())', {
        senderNumber, receiver, message
    }, function(result)
        if result and result.insertId then
            Utils.debugPrint('Message saved with ID: ' .. result.insertId)
            
            -- Check if receiver is online
            local target, targetSrc = GetPlayerByPhone(receiver)
            if target and targetSrc then
                TriggerClientEvent('jrich-phone:receiveMessage', targetSrc, senderNumber, message, os.time())
            end
            
            -- Confirm to sender
            TriggerClientEvent('jrich-phone:notification', src, _('message_sent'), _('message') .. ' ' .. _('success'), 'success')
        else
            Utils.debugPrint('Failed to save message to database')
            TriggerClientEvent('jrich-phone:notification', src, _('message_failed'), _('error'), 'error')
        end
    end)
end)

RegisterServerEvent('jrich-phone:getMessages')
AddEventHandler('jrich-phone:getMessages', function(otherNumber)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local playerNumber = player.PlayerData.charinfo.phone
    
    if otherNumber then
        -- Get conversation with specific number
        ExecuteQuery('SELECT * FROM jrich_phone_messages WHERE (sender_number = ? AND receiver_number = ?) OR (sender_number = ? AND receiver_number = ?) ORDER BY timestamp ASC LIMIT ?', {
            playerNumber, otherNumber, otherNumber, playerNumber, Config.MaxMessages
        }, function(messages)
            TriggerClientEvent('jrich-phone:receiveMessages', src, messages or {})
        end)
    else
        -- Get all conversations
        ExecuteQuery('SELECT DISTINCT CASE WHEN sender_number = ? THEN receiver_number ELSE sender_number END as contact_number FROM jrich_phone_messages WHERE sender_number = ? OR receiver_number = ? ORDER BY timestamp DESC', {
            playerNumber, playerNumber, playerNumber
        }, function(conversations)
            TriggerClientEvent('jrich-phone:receiveMessages', src, conversations or {})
        end)
    end
end)

-- Export functions
exports('GetPlayerPhone', function(src)
    local player = GetPlayer(src)
    return player and player.PlayerData.charinfo.phone or nil
end)

exports('SendNotification', function(src, title, message, type)
    TriggerClientEvent('jrich-phone:notification', src, title, message, type or 'info')
end)

exports('AddBankTransaction', function(citizenid, amount, type, reason, target)
    ExecuteQuery('INSERT INTO jrich_phone_transactions (citizenid, amount, type, reason, target, timestamp) VALUES (?, ?, ?, ?, ?, NOW())', {
        citizenid, amount, type, reason, target
    }, function(result)
        if result then
            Utils.debugPrint('Bank transaction added: ' .. type .. ' $' .. amount .. ' for ' .. citizenid)
        end
    end)
end)

exports('GetPlayerContacts', function(src)
    local player = GetPlayer(src)
    if not player then return {} end
    
    local contacts = {}
    ExecuteQuery('SELECT * FROM jrich_phone_contacts WHERE citizenid = ? ORDER BY name ASC', {player.PlayerData.citizenid}, function(result)
        contacts = result or {}
    end)
    
    return contacts
end)

-- Admin commands
if QBCore.Commands then
    QBCore.Commands.Add('givephone', 'Give a phone to a player (Admin Only)', {
        {name = 'id', help = 'Player ID'},
        {name = 'number', help = 'Phone Number (optional)'}
    }, false, function(source, args)
        local src = source
        local playerId = tonumber(args[1])
        local phoneNumber = args[2]
        
        if not playerId then
            TriggerClientEvent('chat:addMessage', src, {args = {'SYSTEM', 'Invalid player ID'}})
            return
        end
        
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if not targetPlayer then
            TriggerClientEvent('chat:addMessage', src, {args = {'SYSTEM', 'Player not found'}})
            return
        end
        
        if not phoneNumber then
            phoneNumber = math.random(1000000, 9999999)
        end
        
        targetPlayer.PlayerData.charinfo.phone = tostring(phoneNumber)
        targetPlayer.Functions.Save()
        
        CachePlayerData(playerId)
        
        TriggerClientEvent('jrich-phone:notification', playerId, _('app_phone'), 'You received a new phone! Number: ' .. phoneNumber, 'success')
        TriggerClientEvent('chat:addMessage', src, {args = {'SYSTEM', 'Phone given to ' .. targetPlayer.PlayerData.charinfo.firstname .. ' with number ' .. phoneNumber}})
        
        Utils.debugPrint('Admin gave phone to ' .. targetPlayer.PlayerData.charinfo.firstname .. ' - Number: ' .. phoneNumber)
    end, 'admin')
end

-- Player disconnect cleanup
AddEventHandler('playerDropped', function()
    local src = source
    if playerCache[src] then
        playerCache[src] = nil
        Utils.debugPrint('Cleaned up cache for disconnected player: ' .. src)
    end
end)

-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.debugPrint('jrich-phone server starting...')
        InitializeDatabase()
        
        -- Cache all online players
        CreateThread(function()
            Wait(5000) -- Wait for other resources to load
            
            local players = QBCore.Functions.GetQBPlayers()
            for src, player in pairs(players) do
                CachePlayerData(src)
            end
            
            Utils.debugPrint('Cached ' .. Utils.tableLength(playerCache) .. ' online players')
        end)
    end
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.debugPrint('jrich-phone server stopping, cleaning up...')
        playerCache = {}
        Utils.debugPrint('Server cleanup completed')
    end
end)

Utils.debugPrint('Server main script fully loaded')