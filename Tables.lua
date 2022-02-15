local _, addon = ...

local FILTER_METHOD = {}
local SORT_MEDTHOD = {}

local function ListFilter(A, filters)
	if not type(A) == 'table' then return end
	
	local keyLevelLowerBound, keyLevelUpperBound = 2, 999 -- Lowest key possible, some high enough number

	if filters['key_level'] ~= '' and filters['key_level'] ~= '1' then
		local keyFilterText = filters['key_level']
		if tonumber(keyFilterText) then -- only input a single key level
			keyLevelLowerBound = tonumber(keyFilterText)
			keyLevelUpperBound = tonumber(keyFilterText)
		elseif string.match(keyFilterText, '%d+%+') then -- Text input is <number>+, looking for any key at least <number>
			keyLevelLowerBound = tonumber(string.match(keyFilterText, '%d+'))
		elseif string.match(keyFilterText, '%d+%-') then -- Text input is <number>-, looking for a key no higher than <number>
			keyLevelUpperBound = tonumber(string.match(keyFilterText, '%d+'))
		end
	end

	for i = 1, #A do
		if AstralKeysSettings.frame.show_offline.isEnabled then
			A[i].isShown = true
		else
			A[i].isShown = addon.IsUnitOnline(A[i].character_name)
		end

		if not AstralKeysSettings.friendOptions.show_other_faction.isEnabled then
			A[i].isShown = A[i].isShown and tonumber(A[i].faction) == addon.FACTION
		end

		local isShownInFilter = true -- Assume there is no filter taking place
		
		for field, filterText in pairs(filters) do
				if filterText ~= '' then
					isShownInFilter = false -- There is a filter, now assume this unit is not to be shown
					if field == 'dungeon_name' then
						local mapName = addon.GetMapName(A[i]['dungeon_id'])
						if strfind(strlower(mapName), strlower(filterText)) then
							isShownInFilter = true
						end
					elseif field == 'key_level' then
						if A[i][field] >= keyLevelLowerBound and A[i][field] <= keyLevelUpperBound then
							isShownInFilter = true
						end
					else
						if strfind(strlower(A[i][field]):sub(1, A[i][field]:find('-') - 1), strlower(filterText)) then -- or strfind(strlower(A[i].btag), strlower(filterText)) then
							isShownInFilter = true
						end
					end
				end
				A[i].isShown = A[i].isShown and isShownInFilter
			end

		if A[i].isShown then
			A.num_shown = A.num_shown + 1
		end
	end
end

local function CompareUnitNames(a, b)
	local s = string.lower(a.btag or a.character_name)
	local t = string.lower(b.btag or b.character_name)
	if AstralKeysSettings.frame.orientation == 0 then
		if s > t then
			return true
		elseif
			s < t then
			return false
		else
			return string.lower(a.character_name) > string.lower(b.character_name)
		end
	else
		if s < t then
			return true
		elseif
			s > t then
			return false
		else
			return string.lower(a.character_name) < string.lower(b.character_name)
		end
	end
end


local function ListSort(A, v)
	if v == 'dungeon_name' then
		table.sort(A, function(a, b)
			local aOnline = addon.IsUnitOnline(a.character_name) and 1 or 0
			local bOnline = addon.IsUnitOnline(b.character_name) and 1 or 0
			if not AstralKeysSettings.frame.mingle_offline.isEnabled then
				aOnline = true
				bOnline = true
			end
			if aOnline == bOnline then
				if AstralKeysSettings.frame.orientation == 0 then
					if addon.GetMapName(a.dungeon_id) > addon.GetMapName(b.dungeon_id) then
						return true
					elseif addon.GetMapName(b.dungeon_id) > addon.GetMapName(a.dungeon_id) then
						return false
					else
						return a.character_name < b.character_name
					end
				else
					if addon.GetMapName(a.dungeon_id) > addon.GetMapName(b.dungeon_id) then
						return false
					elseif addon.GetMapName(b.dungeon_id) > addon.GetMapName(a.dungeon_id) then
						return true
					else
						return CompareUnitNames(a, b)
					end
				end
			else
				return aOnline > bOnline
			end
		end)
	else
		if v == 'character_name' then
			table.sort(A, function(a, b)
				local aOnline = addon.IsUnitOnline(a.character_name) and 1 or 0
				local bOnline = addon.IsUnitOnline(b.character_name) and 1 or 0
				if not AstralKeysSettings.frame.mingle_offline.isEnabled then
					aOnline = true
					bOnline = true
				end
				if aOnline == bOnline then
					return CompareUnitNames(a, b)
				else
					return aOnline > bOnline
				end
			end)
		else
			table.sort(A, function(a, b) 
				local aOnline = addon.IsUnitOnline(a.character_name) and 1 or 0
				local bOnline = addon.IsUnitOnline(b.character_name) and 1 or 0
				if not AstralKeysSettings.frame.mingle_offline.isEnabled then
					aOnline = true
					bOnline = true
				end
				if aOnline == bOnline then
					if AstralKeysSettings.frame.orientation == 0 then
						if a[v] > b[v] then
							return true
						elseif
							a[v] < b[v]  then
							return false
						else
							return CompareUnitNames(a, b)
						end
					else
						if a[v] < b[v] then
							return true
						elseif
							a[v] > b[v]  then
							return false
						else
							return CompareUnitNames(a, b)
						end
					end
				else
					return aOnline > bOnline
				end
			end)
		end
	end
end

function addon.AddListFilter(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	FILTER_METHOD[list] = f
end

function addon.AddListSort(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	SORT_MEDTHOD[list] = f
end

function addon.UpdateTable(tbl, filters)
	tbl.num_shown = 0
	--FILTER_METHOD[e.FrameListShown()](tbl, filters)
	ListFilter(tbl, filters)
end

function addon.SortTable(A, v)
	ListSort(A, v)
	--SORT_MEDTHOD[e.FrameListShown()](A, v)
end