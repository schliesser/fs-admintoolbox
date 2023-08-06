local debug = true

-- Helper function to print in debug mode
function atbPrint(value)
    if debug then
        print('ATB: ' .. atbDump(value))
    end
end

-- Helper function to debug tables
function atbDump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. atbDump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
