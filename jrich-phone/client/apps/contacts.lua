-- Contacts App Client Handler
local contactsCache = {}

-- Events
RegisterNetEvent('jrich-phone:openApp')
AddEventHandler('jrich-phone:openApp', function(appName)
    if appName ~= 'contacts' then return end
    
    Utils.debugPrint('Opening contacts app')
    TriggerServerEvent('jrich-phone:getContacts')
end)

RegisterNetEvent('jrich-phone:closeApp')
AddEventHandler('jrich-phone:closeApp', function(appName)
    if appName ~= 'contacts' then return end
    
    Utils.debugPrint('Closing contacts app')
    contactsCache = {}
end)

-- NUI Callbacks
RegisterNUICallback('contacts:getAll', function(data, cb)
    TriggerServerEvent('jrich-phone:getContacts')
    cb('ok')
end)

RegisterNUICallback('contacts:add', function(data, cb)
    if not data.name or not data.number then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:addContact', data.name, data.number)
    cb('ok')
end)

RegisterNUICallback('contacts:delete', function(data, cb)
    if not data.id then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:deleteContact', data.id)
    cb('ok')
end)

RegisterNUICallback('contacts:edit', function(data, cb)
    if not data.id or not data.name or not data.number then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:editContact', data.id, data.name, data.number)
    cb('ok')
end)

RegisterNUICallback('contacts:call', function(data, cb)
    if not data.number then
        cb('error')
        return
    end
    
    TriggerServerEvent('jrich-phone:call', data.number)
    cb('ok')
end)

RegisterNUICallback('contacts:message', function(data, cb)
    if not data.number then
        cb('error')
        return
    end
    
    -- Open messages app with this contact
    SendNUIMessage({
        action = 'openApp',
        app = 'messages',
        data = { number = data.number }
    })
    cb('ok')
end)

-- Server response handlers
RegisterNetEvent('jrich-phone:receiveContacts')
AddEventHandler('jrich-phone:receiveContacts', function(contacts)
    contactsCache = contacts
    
    SendNUIMessage({
        action = 'contacts:loaded',
        data = contacts
    })
end)