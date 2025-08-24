-- Contacts App Server Handler

-- Get all contacts for a player
RegisterServerEvent('jrich-phone:getContacts')
AddEventHandler('jrich-phone:getContacts', function()
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    Utils.debugPrint('Fetching contacts for citizen: ' .. citizenid)
    
    ExecuteQuery('SELECT * FROM jrich_phone_contacts WHERE citizenid = ? ORDER BY name ASC', {citizenid}, function(contacts)
        TriggerClientEvent('jrich-phone:receiveContacts', src, contacts or {})
    end)
end)

-- Add a new contact
RegisterServerEvent('jrich-phone:addContact')
AddEventHandler('jrich-phone:addContact', function(name, number)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    -- Validate input
    if not Utils.validatePhoneNumber(number) then
        TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), _('invalid_number'), 'error')
        return
    end
    
    name = Utils.sanitizeString(name)
    if not name or string.len(name) == 0 then
        TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), _('contact_name') .. ' cannot be empty', 'error')
        return
    end
    
    if string.len(name) > 50 then
        name = string.sub(name, 1, 50)
    end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Check if contact already exists
    ExecuteQuery('SELECT COUNT(*) as count FROM jrich_phone_contacts WHERE citizenid = ? AND number = ?', {citizenid, number}, function(result)
        if result and result[1] and result[1].count > 0 then
            TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), _('contact_exists'), 'error')
        else
            -- Check contact limit
            ExecuteQuery('SELECT COUNT(*) as count FROM jrich_phone_contacts WHERE citizenid = ?', {citizenid}, function(countResult)
                if countResult and countResult[1] and countResult[1].count >= Config.MaxContacts then
                    TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), 'Contact limit reached (' .. Config.MaxContacts .. ')', 'error')
                    return
                end
                
                -- Add new contact
                ExecuteQuery('INSERT INTO jrich_phone_contacts (citizenid, name, number) VALUES (?, ?, ?)', {citizenid, name, number}, function(insertResult)
                    if insertResult and insertResult.insertId then
                        Utils.debugPrint('Contact added: ' .. name .. ' (' .. number .. ') for ' .. citizenid)
                        TriggerClientEvent('jrich-phone:notification', src, _('contact_added'), name .. ' added to contacts', 'success')
                        
                        -- Refresh contacts list
                        TriggerEvent('jrich-phone:getContacts', src)
                    else
                        TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), 'Database error', 'error')
                    end
                end)
            end)
        end
    end)
end)

-- Edit existing contact
RegisterServerEvent('jrich-phone:editContact')
AddEventHandler('jrich-phone:editContact', function(contactId, name, number)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    -- Validate input
    if not Utils.validatePhoneNumber(number) then
        TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), _('invalid_number'), 'error')
        return
    end
    
    name = Utils.sanitizeString(name)
    if not name or string.len(name) == 0 then
        TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), _('contact_name') .. ' cannot be empty', 'error')
        return
    end
    
    if string.len(name) > 50 then
        name = string.sub(name, 1, 50)
    end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Update contact
    ExecuteQuery('UPDATE jrich_phone_contacts SET name = ?, number = ?, updated_at = NOW() WHERE id = ? AND citizenid = ?', {name, number, contactId, citizenid}, function(result)
        if result and result.affectedRows > 0 then
            Utils.debugPrint('Contact updated: ' .. name .. ' (' .. number .. ') for ' .. citizenid)
            TriggerClientEvent('jrich-phone:notification', src, _('contact_updated'), name .. ' contact updated', 'success')
            
            -- Refresh contacts list
            TriggerEvent('jrich-phone:getContacts', src)
        else
            TriggerClientEvent('jrich-phone:notification', src, _('contact_failed'), 'Contact not found', 'error')
        end
    end)
end)

-- Delete contact
RegisterServerEvent('jrich-phone:deleteContact')
AddEventHandler('jrich-phone:deleteContact', function(contactId)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Get contact name for confirmation
    ExecuteQuery('SELECT name FROM jrich_phone_contacts WHERE id = ? AND citizenid = ?', {contactId, citizenid}, function(contact)
        if contact and contact[1] then
            local contactName = contact[1].name
            
            -- Delete contact
            ExecuteQuery('DELETE FROM jrich_phone_contacts WHERE id = ? AND citizenid = ?', {contactId, citizenid}, function(result)
                if result and result.affectedRows > 0 then
                    Utils.debugPrint('Contact deleted: ID ' .. contactId .. ' for ' .. citizenid)
                    TriggerClientEvent('jrich-phone:notification', src, _('contact_deleted'), contactName .. ' removed from contacts', 'success')
                    
                    -- Refresh contacts list
                    TriggerEvent('jrich-phone:getContacts', src)
                else
                    TriggerClientEvent('jrich-phone:notification', src, _('delete_failed'), 'Contact not found', 'error')
                end
            end)
        else
            TriggerClientEvent('jrich-phone:notification', src, _('delete_failed'), 'Contact not found', 'error')
        end
    end)
end)

-- Toggle favorite status
RegisterServerEvent('jrich-phone:toggleFavorite')
AddEventHandler('jrich-phone:toggleFavorite', function(contactId)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    
    -- Toggle favorite status
    ExecuteQuery('UPDATE jrich_phone_contacts SET favorite = NOT favorite WHERE id = ? AND citizenid = ?', {contactId, citizenid}, function(result)
        if result and result.affectedRows > 0 then
            -- Refresh contacts list
            TriggerEvent('jrich-phone:getContacts', src)
        end
    end)
end)