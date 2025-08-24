Locale = {}

-- Current locale
Locale.current = Config.Locale or 'en'

-- Localization data
Locale.data = {
    ['en'] = {
        -- Common
        ['yes'] = 'Yes',
        ['no'] = 'No',
        ['cancel'] = 'Cancel',
        ['confirm'] = 'Confirm',
        ['delete'] = 'Delete',
        ['edit'] = 'Edit',
        ['save'] = 'Save',
        ['back'] = 'Back',
        ['close'] = 'Close',
        ['loading'] = 'Loading...',
        ['error'] = 'Error',
        ['success'] = 'Success',
        ['warning'] = 'Warning',
        ['info'] = 'Info',
        
        -- Phone
        ['phone_locked'] = 'Phone Locked',
        ['slide_to_unlock'] = 'Slide to unlock',
        ['phone_unlocked'] = 'Phone Unlocked',
        ['phone_battery_low'] = 'Battery Low',
        ['phone_battery_critical'] = 'Battery Critical',
        ['phone_charging'] = 'Charging',
        
        -- Apps
        ['app_phone'] = 'Phone',
        ['app_messages'] = 'Messages',
        ['app_contacts'] = 'Contacts',
        ['app_bank'] = 'Bank',
        ['app_garage'] = 'Garage',
        ['app_camera'] = 'Camera',
        ['app_gallery'] = 'Gallery',
        ['app_notes'] = 'Notes',
        ['app_calculator'] = 'Calculator',
        ['app_settings'] = 'Settings',
        
        -- Phone App
        ['recent_calls'] = 'Recent Calls',
        ['missed_calls'] = 'Missed Calls',
        ['incoming_call'] = 'Incoming Call',
        ['outgoing_call'] = 'Outgoing Call',
        ['call_ended'] = 'Call Ended',
        ['call_failed'] = 'Call Failed',
        ['call_busy'] = 'Line Busy',
        ['call_no_answer'] = 'No Answer',
        ['dial_number'] = 'Dial Number',
        ['calling'] = 'Calling...',
        ['call_duration'] = 'Duration',
        
        -- Messages App
        ['new_message'] = 'New Message',
        ['message_sent'] = 'Message Sent',
        ['message_failed'] = 'Message Failed',
        ['message_received'] = 'Message Received',
        ['type_message'] = 'Type a message...',
        ['send_message'] = 'Send',
        ['no_messages'] = 'No messages',
        ['conversation_with'] = 'Conversation with %s',
        ['message_too_long'] = 'Message too long',
        ['message_empty'] = 'Message cannot be empty',
        
        -- Contacts App
        ['add_contact'] = 'Add Contact',
        ['edit_contact'] = 'Edit Contact',
        ['delete_contact'] = 'Delete Contact',
        ['contact_name'] = 'Name',
        ['contact_number'] = 'Phone Number',
        ['contact_added'] = 'Contact Added',
        ['contact_deleted'] = 'Contact Deleted',
        ['contact_updated'] = 'Contact Updated',
        ['contact_exists'] = 'Contact already exists',
        ['invalid_number'] = 'Invalid phone number',
        ['no_contacts'] = 'No contacts',
        ['search_contacts'] = 'Search contacts...',
        ['favorite_contacts'] = 'Favorites',
        
        -- Bank App
        ['account_balance'] = 'Account Balance',
        ['recent_transactions'] = 'Recent Transactions',
        ['transfer_money'] = 'Transfer Money',
        ['transfer_to'] = 'Transfer to',
        ['transfer_amount'] = 'Amount',
        ['transfer_reason'] = 'Reason',
        ['transfer_successful'] = 'Transfer Successful',
        ['transfer_failed'] = 'Transfer Failed',
        ['insufficient_funds'] = 'Insufficient Funds',
        ['invalid_amount'] = 'Invalid Amount',
        ['recipient_not_found'] = 'Recipient not found',
        ['transaction_deposit'] = 'Deposit',
        ['transaction_withdraw'] = 'Withdraw',
        ['transaction_transfer_in'] = 'Transfer In',
        ['transaction_transfer_out'] = 'Transfer Out',
        ['no_transactions'] = 'No transactions',
        
        -- Garage App
        ['my_vehicles'] = 'My Vehicles',
        ['vehicle_location'] = 'Location',
        ['vehicle_status'] = 'Status',
        ['vehicle_fuel'] = 'Fuel',
        ['vehicle_engine'] = 'Engine',
        ['vehicle_body'] = 'Body',
        ['vehicle_in_garage'] = 'In Garage',
        ['vehicle_out'] = 'Out',
        ['vehicle_impounded'] = 'Impounded',
        ['set_gps'] = 'Set GPS',
        ['no_vehicles'] = 'No vehicles',
        
        -- Settings App
        ['wallpaper'] = 'Wallpaper',
        ['ringtone'] = 'Ringtone',
        ['volume'] = 'Volume',
        ['brightness'] = 'Brightness',
        ['notifications'] = 'Notifications',
        ['privacy'] = 'Privacy',
        ['about'] = 'About',
        ['settings_updated'] = 'Settings Updated',
        
        -- Notifications
        ['notification_new_message'] = 'New message from %s',
        ['notification_missed_call'] = 'Missed call from %s',
        ['notification_low_battery'] = 'Battery is running low (%d%%)',
        ['notification_money_received'] = 'Received $%s from %s',
        ['notification_money_sent'] = 'Sent $%s to %s',
        
        -- Status Bar
        ['carrier_los_santos'] = 'Los Santos Mobile',
        ['carrier_blaine_county'] = 'Blaine County Wireless',
    }
}

-- Function to get localized string
function Locale:Get(key, ...)
    local locale = self.data[self.current] or self.data['en']
    local str = locale[key] or key
    
    if ... then
        return string.format(str, ...)
    end
    
    return str
end

-- Shorthand function
function _(key, ...)
    return Locale:Get(key, ...)
end