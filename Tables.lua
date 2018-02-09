local _, e = ...

local FILTER_METHOD = {}
local SORT_MEDTHOD = {}

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

function e.AddListFilter(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	FILTER_METHOD[list] = f
end

function e.AddListSort(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	SORT_MEDTHOD[list] = f
end

SORT_MEDTHOD['guild'] = function(A, v)
	if v == 3 then
		table.sort(A, function(a, b) 
			if AstralKeysSettings.frameOptions.orientation == 0 then
				if e.GetMapName(a[v]) > e.GetMapName(b[v]) then
					return true
				elseif e.GetMapName(a[v]) < e.GetMapName(b[v]) then
					return false
				else
					return a[1] > b[1]
				end
			else
				if e.GetMapName(a[v]) < e.GetMapName(b[v]) then
					return true
				elseif e.GetMapName(a[v]) > e.GetMapName(b[v]) then
					return false
				else
					return a[1] < b[1]
				end
			end
			end)
	else
		table.sort(A, function(a, b)
			if AstralKeysSettings.frameOptions.orientation == 0 then
				if a[v] > b[v] then
					return true
				elseif a[v] < b[v] then
					return false
				else
					return a[1] > b[1]
				end
			else
				if a[v] < b[v] then
					return true
				elseif a[v] > b[v] then
					return false
				else
					return a[1] < b[1]
				end
			end
		end)
	end
end

function e.UpdateTable(tbl)
	tbl.numShown = 0
	FILTER_METHOD[e.FrameListShown()](tbl)
end

function e.SortTable(A, v)
	SORT_MEDTHOD[e.FrameListShown()](A, v)
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