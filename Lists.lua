local e, L = unpack(select(2, ...))

-- Function to be called depenending on which list is being viewed, list being viewed retrieved by e.FrameListShown()
local UNIT_FUNCTION = {}

function e.AddUnitFunction(list, f)
	if type(list) ~= 'string' or list == '' then return end
	if type(f) ~= 'function' then return end

	if UNIT_FUNCTION[list] then
		error('Function already associated with the list ' .. list)
		return
	end
	UNIT_FUNCTION[list] = f
end

function e.GetListFunction(list)
	if not list or type(list) ~= 'string' then return end

	return UNIT_FUNCTION[list]
end