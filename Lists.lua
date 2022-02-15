local _, addon = ...

-- Function to be called depenending on which list is being viewed, list being viewed retrieved by e.FrameListShown()
local UNIT_FUNCTION = {}

-- Adds a function for handling the display of list information
-- @param list String The name of the list to add
-- @param f Function The function to be used the list
function addon.AddUnitFunction(list, f)
	if type(list) ~= 'string' or list == '' then return end
	if type(f) ~= 'function' then return end

	if UNIT_FUNCTION[list] then
		error('Function already associated with the list ' .. list)
		return
	end
	UNIT_FUNCTION[list] = f
end


-- Returns list function associated with a list
-- @param list String list name to query
-- @return function Function associated with the given list
function addon.GetListFunction(list)
	if not list or type(list) ~= 'string' then return end

	return UNIT_FUNCTION[list]
end