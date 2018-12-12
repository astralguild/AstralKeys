local e, L = unpack(select(2, ...))

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