local _, e = ...

local FILTER_METHOD = {}

FILTER_METHOD['guild'] = function(A)
	if not type(A) == 'table' then return end

	for i = 1, #A.guild do
		if e.UnitInGuild(A.guild[i][1]) then
			if AstralKeysSettings.options.showOffline then
				A.guild[i].isShown = true
			else
				A.guild[i].isShown = e.GuildMemberOnline(A.guild[i][1])
			end

			A.guild[i].isShown = A.guild[i].isShown and AstralKeysSettings.options.rankFilters[e.GuildMemberRank(A.guild[i][1])]

			if A.guild[i].isShown then
				A.numShown = A.numShown + 1
			end
		else
			A.guild[i].isShown = false
		end
	end
end

FILTER_METHOD['friend'] = function(A)
	if not type(A) == 'table' then return end

	for i = 1, #A.friend do
		if AstralKeysSettings.options.showOffline then
			A.friend[i].isShown = true
		else
			A.friend[i].isShown = e.IsFriendOnline(A.friend[i][1])
		end

		if not AstralKeysSettings.options.showOtherFaction then
			A.friend[i].isShown = A.friend[i].isShown and tonumber(A.friend[i][6]) == e.FACTION
		end

		if A.friend[i].isShown then
			A.numShown = A.numShown + 1
		end
	end
end

function e.AddSortMethod(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	FILTER_METHOD[list] = f
end

function e.UpdateTable(tbl)
	tbl.numShown = 0
	FILTER_METHOD[e.FrameListShown()](tbl)
end

function e.SortTable(A, v)
	if v == 3 then -- Map Name
		--if e.FrameListShown() == 'friends' then v = v + 1 end
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

	    if AstralKeysSettings.frameOptions.orientation == 0 then
	    	table.sort(A, function(a, b) return e.GetMapName(a[v]) > e.GetMapName(b[v]) end)
	    end
	else
		--if e.FrameListShown() == 'friends' then v = v + 1 end
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

	    if AstralKeysSettings.frameOptions.orientation == 0 then
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