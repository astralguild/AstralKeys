local _, addon = ...

addon.Debug = false

function addon.Console(...)
	print(WrapTextInColorCode('[AK]', '008888FF'), ...)
end

function addon.PrintDebug(...)
    if addon.Debug then
        addon.Console(WrapTextInColorCode('D', 'C1E1C1FF'), ...)
    end
end

function addon.DebugTableToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. addon.DebugTableToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end