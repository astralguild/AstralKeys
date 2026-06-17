local _, addon = ...

local uiScale, mult

addon.refreshTime = 0

ASTRAL_KEYS_REFRESH_INTERVAL = 30 -- seconds

function addon:SetUIScale()
	local scale = string.match( GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" )
	local physicalHeight = select(2, GetPhysicalScreenSize())
	uiScale = UIParent:GetScale()
	if scale then
		mult = 768/scale/uiScale
	else
		mult = 768/physicalHeight
	end
end

function addon:Scale(x)
	return mult * floor(x/mult+.5)
end