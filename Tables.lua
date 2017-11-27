local _, e = ...

local function ParseOnlineUnits(A)
	local tbl = {}
	local units = {}
	local guildName
	local numOnline = select(2, GetNumGuildMembers())
	for i = 1, numOnline do
		guildName = GetGuildRosterInfo(i)
		units[guildName] = true
	end

	for k, v in pairs(A) do
		if units[v[1]] then
			tbl[#tbl+1] = v
		end
	end

	return tbl
end

function e.UpdateTables(table)
	table = e.DeepCopy(AstralKeys)
	if not e.GetShowOffline() then
		table = ParseOnlineUnits(table)
	end

	return table
end

function e.SortTable(A, v)
	if v == 3 then -- Map Name
	    for j = 2, #A do
	        --Select item to sort
	        local key = A[j]
	        local i = j - 1
	        while (i > 0) and (e.GetMapName(A[i][v]) > e.GetMapName(key[v])) do
	            --Move placement index back
	            A[i + 1] = A[i]
	            i = i - 1
	        end
	        --Place current item back into the list
	        A[i + 1] = key
	    end

	    if e.GetOrientation() == 0 then
	    	table.sort(A, function(a, b) return e.GetMapName(a[v]) > e.GetMapName(b[v]) end)
	    end
	else
	    for j = 2, #A do
	        --Select item to sort
	        local key = A[j]
	        local i = j - 1
	        while (i > 0) and (A[i][v] > key[v]) do
	            --Move placement index back
	            A[i + 1] = A[i]
	            i = i - 1
	        end
	        --Place current item back into the list
	        A[i + 1] = key
	    end

	    if e.GetOrientation() == 0 then
	    	table.sort(A, function(a, b) return a[v] > b[v] end)
	    end
	end
end

function e.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
    	copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[e.DeepCopy(orig_key)] = e.DeepCopy(orig_value)
        end
        setmetatable(copy, e.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end