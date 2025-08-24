Utils = {}

-- Debug function
function Utils.debugPrint(msg)
    if Config and Config.Debug then
        print('[^5jrich-phone^7] ' .. tostring(msg))
    end
end

-- Validate phone number
function Utils.validatePhoneNumber(number)
    if not number or type(number) ~= 'string' then
        return false
    end
    
    local cleaned = string.gsub(number, '%D', '')
    return string.len(cleaned) >= 7 and string.len(cleaned) <= 15
end

-- Format phone number
function Utils.formatPhoneNumber(number)
    if not number then return 'Unknown' end
    
    local cleaned = string.gsub(tostring(number), '%D', '')
    
    if string.len(cleaned) == 10 then
        return string.format('(%s) %s-%s', string.sub(cleaned, 1, 3), string.sub(cleaned, 4, 6), string.sub(cleaned, 7, 10))
    else
        return tostring(number)
    end
end

-- Generate random ID
function Utils.generateId(length)
    length = length or 8
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local id = ''
    
    for i = 1, length do
        local rand = math.random(#chars)
        id = id .. string.sub(chars, rand, rand)
    end
    
    return id
end

-- Sanitize string
function Utils.sanitizeString(str)
    if not str or type(str) ~= 'string' then return '' end
    
    str = string.gsub(str, "'", "''")
    str = string.gsub(str, '"', '""')
    str = string.gsub(str, ';', '')
    str = string.gsub(str, '--', '')
    str = string.gsub(str, '^%s*(.-)%s*$', '%1')
    
    return str
end

-- Get random carrier
function Utils.getRandomCarrier()
    local carriers = {'Los Santos Mobile', 'Blaine County Wireless', 'Verizon', 'AT&T'}
    return carriers[math.random(#carriers)]
end

-- Table length
function Utils.tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end