local _, addon = ...

addon[1] = {} -- engine
addon[2] = {} -- Localization

local e = addon[1]
local uiScale, mult

function e:SetUIScale()
	local screenHeight = UIParent:GetHeight()
	local scale = string.match(GetCVar("gxWindowedResolution"), "%d+x(%d+)")
	uiScale = UIParent:GetScale()
	mult = 768 / scale / uiScale
end

function e:Scale(x)
	return mult * floor(x / mult + .5)
end