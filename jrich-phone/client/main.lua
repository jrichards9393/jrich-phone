local QBCore = exports['qb-core']:GetCoreObject()

-- Phone state
local phoneOpen = false
local phoneModel = nil
local currentApp = nil
local lastActivity = 0

-- Animation settings
local animDict = Config.Animation.dict
local anim = Config.Animation.anim

-- Verify QBCore
if not QBCore then
    Utils.debugPrint('ERROR: QBCore not found! Ensure qb-core is running.')
    return
end

Utils.debugPrint('Phone client loaded successfully')

-- Phone state management
local PhoneState = {
    isOpen = false,
    isLocked = true,
    currentWallpaper = Config.DefaultWallpaper,
    currentRingtone = Config.Ringtone,
    battery = 100,
    signal = 3,
    carrier = Utils.getRandomCarrier(),
    notifications = {}
}

-- Initialize phone
local function InitializePhone()
    Utils.debugPrint('Initializing phone...')
    
    -- Load user settings
    TriggerServerEvent('jrich-phone:loadSettings')
    
    -- Update time every second
    CreateThread(function()
        while true do
            Wait(1000)
            SendNUIMessage({
                action = 'updateTime'
            })
        end
    end)
    
    -- Battery simulation (if enabled)
    if Config.Battery and Config.Battery.enabled then
        CreateThread(function()
            while true do
                Wait(60000) -- Every minute
                
                if phoneOpen then
                    PhoneState.battery = math.max(0, PhoneState.battery - Config.Battery.drainRate)
                    
                    if PhoneState.battery <= Config.Battery.lowBatteryWarning then
                        TriggerEvent('jrich-phone:notification', _('phone_battery_low'), _('notification_low_battery', PhoneState.battery), 'warning')
                    end
                    
                    SendNUIMessage({
                        action = 'updateBattery',
                        battery = PhoneState.battery
                    })
                end
            end
        end)
    end
end

-- Phone opening with enhanced animation
local function OpenPhone()
    if phoneOpen then
        Utils.debugPrint('Phone already open')
        return
    end
    
    Utils.debugPrint('Opening phone...')
    
    -- Set NUI focus and send message
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        config = {
            apps = Config.Apps,
            wallpaper = PhoneState.currentWallpaper,
            carrier = PhoneState.carrier,
            battery = PhoneState.battery,
            signal = PhoneState.signal
        }
    })
    
    phoneOpen = true
    lastActivity = GetGameTimer()
    
    -- Load and play animation
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    
    local playerPed = PlayerPedId()
    TaskPlayAnim(playerPed, animDict, anim, 8.0, -8.0, Config.Animation.duration, Config.Animation.flag, 0, false, false, false)
    
    -- Create phone prop if enabled
    if Config.UsePhoneProp then
        CreatePhoneProp()
    end
    
    -- Play unlock sound
    if Config.Sounds.enabled and Config.Sounds.uiSounds then
        PlaySound('unlock')
    end
    
    Utils.debugPrint('Phone opened successfully')
end

-- Enhanced phone closing
local function ClosePhone()
    if not phoneOpen then
        Utils.debugPrint('Phone already closed')
        return
    end
    
    Utils.debugPrint('Closing phone...')
    
    -- Send close message to NUI
    SendNUIMessage({
        action = 'close'
    })
    
    -- Remove NUI focus
    SetNuiFocus(false, false)
    phoneOpen = false
    currentApp = nil
    
    -- Clear player tasks
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    
    -- Remove phone prop
    if phoneModel then
        DeleteObject(phoneModel)
        phoneModel = nil
    end
    
    -- Play lock sound
    if Config.Sounds.enabled and Config.Sounds.uiSounds then
        PlaySound('lock')
    end
    
    -- Safety reset for stuck NUI focus
    CreateThread(function()
        Wait(200)
        if IsNuiFocused() then
            Utils.debugPrint('Force resetting stuck NUI focus')
            SetNuiFocus(false, false)
        end
    end)
    
    Utils.debugPrint('Phone closed successfully')
end

-- Create phone prop
function CreatePhoneProp()
    if phoneModel then return end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    RequestModel(GetHashKey(Config.PhoneModel))
    while not HasModelLoaded(GetHashKey(Config.PhoneModel)) do
        Wait(10)
    end
    
    phoneModel = CreateObject(GetHashKey(Config.PhoneModel), coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(phoneModel, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end

-- Play sound
function PlaySound(soundName)
    if not Config.Sounds.enabled then return end
    
    if GetResourceState('interact-sound') == 'started' then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'phone_' .. soundName, Config.Sounds.volume)
    end
end

-- Auto-lock functionality
CreateThread(function()
    while true do
        Wait(1000)
        
        if phoneOpen and Config.Security.autoLock then
            local timeSinceActivity = (GetGameTimer() - lastActivity) / 1000
            
            if timeSinceActivity >= Config.Security.autoLockTime then
                SendNUIMessage({
                    action = 'lockPhone'
                })
                lastActivity = GetGameTimer()
            end
        end
    end
end)

-- Error handling and recovery
CreateThread(function()
    while true do
        Wait(5000)
        
        -- Check for stuck NUI focus
        if phoneOpen and not IsNuiFocused() then
            Utils.debugPrint('WARNING: Phone is open but NUI focus lost, recovering...')
            SetNuiFocus(true, true)
        end
        
        -- Check for missing animation
        if phoneOpen and not IsEntityPlayingAnim(PlayerPedId(), animDict, anim, 3) then
            Utils.debugPrint('Phone animation stopped, restarting...')
            TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, -8.0, Config.Animation.duration, Config.Animation.flag, 0, false, false, false)
        end
    end
end)

-- Key mapping
RegisterKeyMapping('+openPhone', 'Open/Close Phone', 'keyboard', 'F1')

-- Command to toggle phone
RegisterCommand('+openPhone', function()
    if not phoneOpen then
        OpenPhone()
    else
        ClosePhone()
    end
end, false)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    ClosePhone()
    cb('ok')
end)

RegisterNUICallback('unlock', function(data, cb)
    PhoneState.isLocked = false
    lastActivity = GetGameTimer()
    cb('ok')
end)

RegisterNUICallback('lock', function(data, cb)
    PhoneState.isLocked = true
    cb('ok')
end)

RegisterNUICallback('openApp', function(data, cb)
    if not data.app then
        cb('error')
        return
    end
    
    currentApp = data.app
    lastActivity = GetGameTimer()
    Utils.debugPrint('Opening app: ' .. currentApp)
    
    -- Trigger app-specific events
    TriggerEvent('jrich-phone:openApp', currentApp)
    cb('ok')
end)

RegisterNUICallback('closeApp', function(data, cb)
    if currentApp then
        TriggerEvent('jrich-phone:closeApp', currentApp)
        currentApp = nil
    end
    cb('ok')
end)

-- Phone number callbacks
RegisterNUICallback('call', function(data, cb)
    if not data.number then
        cb('error')
        return
    end
    
    Utils.debugPrint('Initiating call to ' .. data.number)
    TriggerServerEvent('jrich-phone:call', data.number)
    cb('ok')
end)

RegisterNUICallback('answerCall', function(data, cb)
    if not data.number then
        cb('error')
        return
    end
    
    Utils.debugPrint('Answering call from ' .. data.number)
    TriggerServerEvent('jrich-phone:answerCall', data.number)
    cb('ok')
end)

RegisterNUICallback('endCall', function(data, cb)
    if data.number then
        TriggerServerEvent('jrich-phone:endCall', data.number)
    end
    cb('ok')
end)

-- Message callbacks
RegisterNUICallback('sendMessage', function(data, cb)
    if not data.receiver or not data.message then
        cb('error')
        return
    end
    
    Utils.debugPrint('Sending message to ' .. data.receiver)
    TriggerServerEvent('jrich-phone:sendMessage', data.receiver, data.message)
    cb('ok')
end)

RegisterNUICallback('getMessages', function(data, cb)
    Utils.debugPrint('Fetching messages')
    TriggerServerEvent('jrich-phone:getMessages', data.number)
    cb('ok')
end)

-- Contact callbacks
RegisterNUICallback('getContacts', function(data, cb)
    Utils.debugPrint('Fetching contacts')
    TriggerServerEvent('jrich-phone:getContacts')
    cb('ok')
end)

RegisterNUICallback('addContact', function(data, cb)
    if not data.name or not data.number then
        cb('error')
        return
    end
    
    Utils.debugPrint('Adding contact: ' .. data.name)
    TriggerServerEvent('jrich-phone:addContact', data.name, data.number)
    cb('ok')
end)

RegisterNUICallback('deleteContact', function(data, cb)
    if not data.id then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:deleteContact', data.id)
    cb('ok')
end)

-- Bank callbacks
RegisterNUICallback('getBank', function(data, cb)
    Utils.debugPrint('Fetching bank information')
    TriggerServerEvent('jrich-phone:getBank')
    cb('ok')
end)

RegisterNUICallback('transferMoney', function(data, cb)
    if not data.target or not data.amount then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:transferMoney', data.target, data.amount, data.reason)
    cb('ok')
end)

-- Vehicle callbacks
RegisterNUICallback('getVehicles', function(data, cb)
    Utils.debugPrint('Fetching vehicles')
    TriggerServerEvent('jrich-phone:getVehicles')
    cb('ok')
end)

RegisterNUICallback('setGPS', function(data, cb)
    if not data.x or not data.y then
        cb('error')
        return
    end
    
    SetNewWaypoint(tonumber(data.x), tonumber(data.y))
    TriggerEvent('jrich-phone:notification', _('gps'), _('waypoint_set'), 'success')
    cb('ok')
end)

-- Settings callbacks
RegisterNUICallback('updateSettings', function(data, cb)
    if data.wallpaper then
        PhoneState.currentWallpaper = data.wallpaper
        TriggerServerEvent('jrich-phone:updateSetting', 'wallpaper', data.wallpaper)
    end
    
    if data.ringtone then
        PhoneState.currentRingtone = data.ringtone
        TriggerServerEvent('jrich-phone:updateSetting', 'ringtone', data.ringtone)
    end
    
    cb('ok')
end)

-- Network Events
RegisterNetEvent('jrich-phone:receiveContacts', function(contacts)
    Utils.debugPrint('Received ' .. #contacts .. ' contacts from server')
    SendNUIMessage({
        action = 'loadContacts',
        data = contacts
    })
end)

RegisterNetEvent('jrich-phone:receiveMessages', function(messages)
    Utils.debugPrint('Received ' .. #messages .. ' messages from server')
    SendNUIMessage({
        action = 'loadMessages',
        data = messages
    })
end)

RegisterNetEvent('jrich-phone:updateBank', function(balance, transactions)
  debugPrint('Bank update: Balance = $' .. tostring(balance))
    SendNUIMessage({
        action = 'updateBank',
        balance = balance,
        transactions = transactions
    })
end)

RegisterNetEvent('jrich-phone:updateVehicles', function(vehicles)
    Utils.debugPrint('Vehicle list updated: ' .. #vehicles .. ' vehicles')
    SendNUIMessage({
        action = 'loadVehicles',
        data = vehicles
    })
end)

RegisterNetEvent('jrich-phone:notification', function(title, message, type)
    local notifType = type or 'info'
    Utils.debugPrint('Notification: ' .. title .. ' - ' .. message)
    
    -- Add to notifications list
    table.insert(PhoneState.notifications, {
        id = Utils.generateId(),
        title = title,
        message = message,
        type = notifType,
        timestamp = os.time()
    })
    
    -- Send to NUI
    SendNUIMessage({
        action = 'notification',
        title = title,
        message = message,
        type = notifType
    })
    
    -- Also show ox_lib notification if available
    if lib and lib.notify then
        lib.notify({
            title = title,
            description = message,
            type = notifType,
            duration = 5000
        })
    end
end)

RegisterNetEvent('jrich-phone:incomingCall', function(callerNumber, callerName)
    Utils.debugPrint('Incoming call from: ' .. callerNumber)
    
    -- Play ringtone
    if Config.Sounds.enabled and Config.Sounds.callSound then
        PlaySound('ringtone')
    end
    
    SendNUIMessage({
        action = 'incomingCall',
        number = callerNumber,
        name = callerName or Utils.formatPhoneNumber(callerNumber)
    })
end)

RegisterNetEvent('jrich-phone:callEnded', function()
    Utils.debugPrint('Call ended')
    
    -- Stop ringtone
    if GetResourceState('interact-sound') == 'started' then
        TriggerEvent('InteractSound_CL:StopSound')
    end
    
    SendNUIMessage({
        action = 'callEnded'
    })
end)

RegisterNetEvent('jrich-phone:receiveMessage', function(sender, message, timestamp)
    Utils.debugPrint('New message from: ' .. sender)
    
    -- Play notification sound
    if Config.Sounds.enabled and Config.Messaging.messageSound then
        PlaySound('message')
    end
    
    SendNUIMessage({
        action = 'newMessage',
        sender = sender,
        message = message,
        timestamp = timestamp
    })
    
    -- Show notification
    TriggerEvent('jrich-phone:notification', _('new_message'), _('notification_new_message', Utils.formatPhoneNumber(sender)), 'info')
end)

RegisterNetEvent('jrich-phone:forceClose', function()
    Utils.debugPrint('Phone force closed by server')
    if phoneOpen then
        ClosePhone()
    end
end)

RegisterNetEvent('jrich-phone:updateSettings', function(settings)
    if settings.wallpaper then
        PhoneState.currentWallpaper = settings.wallpaper
    end
    if settings.ringtone then
        PhoneState.currentRingtone = settings.ringtone
    end
    
    SendNUIMessage({
        action = 'updateSettings',
        settings = settings
    })
end)

-- Player loaded event
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Utils.debugPrint('Player loaded, initializing phone...')
    
    CreateThread(function()
        Wait(2000)
        InitializePhone()
        TriggerServerEvent('jrich-phone:playerLoaded')
    end)
end)

-- Exports
exports('IsPhoneOpen', function()
    return phoneOpen
end)

exports('OpenPhone', function()
    OpenPhone()
end)

exports('ClosePhone', function()
    ClosePhone()
end)

exports('SendNUIMessage', function(data)
    SendNUIMessage(data)
end)

exports('GetPhoneSettings', function()
    return PhoneState
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.debugPrint('Resource stopping, cleaning up...')
        
        if phoneOpen then
            SetNuiFocus(false, false)
            ClearPedTasks(PlayerPedId())
        end
        
        if phoneModel then
            DeleteObject(phoneModel)
        end
        
        Utils.debugPrint('Client cleanup completed')
    end
end)

Utils.debugPrint('Client main script fully loaded')