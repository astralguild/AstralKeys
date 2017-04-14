local _, e = ...

local data = {}

local function ParseOnlineUnits(A)
	tprint(A[2])
	local guildName, online
	for i = 1, select(2, GetNumGuildMembers()) do
		guildName = GetGuildRosterInfo(i)
		guildName = Ambiguate(guildName, 'GUILD')
		for n = 1, #A do
			if A[n]['realm'] then
			 	if A[n]['realm'] == e.PlayerRealm() then
					if A[n].name ~= guildName then
						table.remove(A, n)
					end
				end
			else
				table.remove(A, n)
			end
		end
	end
end

function e.UpdateTables()
	wipe(data)
	data = e.DeepCopy(AstralKeys)
	if not e.GetShowOffline() then
		ParseOnlineUnits(data)
	end

	return data
end

function e.SortTable(A, v)
	if v == 'map' then
	    for j = 2, #A do
	        --Select item to sort
	        key = A[j]
	        i = j - 1
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
	        key = A[j]
	        i = j - 1
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

