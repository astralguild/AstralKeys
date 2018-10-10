local _, e = ...

local FILTER_METHOD = {}
local SORT_MEDTHOD = {}

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