local _, addon = ...

local uiScale, mult

function addon:SetUIScale()
	local scale = string.match( GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" )
	uiScale = UIParent:GetScale()
	mult = 768/scale/uiScale
end

function addon:Scale(x)
	return mult * floor(x/mult+.5)
end