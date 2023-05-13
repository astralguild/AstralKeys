local _, addon = ...

local uiScale, mult

addon.refreshTime = 0

ASTRAL_KEYS_REFRESH_INTERVAL = 30 -- seconds

function addon:SetUIScale()
	local scale = string.match( GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" )
	uiScale = UIParent:GetScale()
	mult = 768/scale/uiScale
end

function addon:Scale(x)
	return mult * floor(x/mult+.5)
end