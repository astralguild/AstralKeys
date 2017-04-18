local _, e = ...

local akEvents = CreateFrame('FRAME')

akEvents:SetScript("OnEvent", function(self, event, ...)
		--akEvents[event](self, ...)
		akEvents[event](...)
end)


function e.RegisterEvent(event, func)
	akEvents:RegisterEvent(event)
	--akEvents[event] = function(self, ...)
	akEvents[event] = function(...)
	func(...)
	end
end

function e.UnregisterEvent(event)
	akEvents:UnregisterEvent(event)
	akEvents[event] = nil
end

e.RegisterEvent('CHAT_MSG_LOOT', function(...)

		local msg = ...
		local sender = select(5, ...) -- Should return unit that looted
		if not sender == e.PlayerName() then return end
		--if not msg:find('You') then return end

		if msg:find('Keystone') then
			e.FindKeyStone(true, true)
			e.UnregisterEvent('CHAT_MSG_LOOT')
		end

		end)

--[[
e.RegisterEvent('CHAT_MSG_SYSTEM', function(...)
	local msg = ...
	if msg:find('Artifact Power') then
		local amount = msg:sub(msg:find('%s%d'), msg:find('%d%s'))
		if amount:find(',') then
			amount = amount:gsub(',', '')
			print(amount)
			amount = tonumber(amount)
			print(amount .. ' type: ' .. type(amount))
		end
	end
	end)
]]


--[[
where link = CHAT_SYSTEM_MSG where 'Artifact Power' is found.

delink = link:sub(link:find('%s%d'), link:find('%d%s'))
amount = delink:gsub(',', '')

/script print(link:sub(link:find('%s%d'), link:find('%d%s')))

/script print((link:sub(link:find('%s%d'), link:find('%d%s'))):gsub(',', ''))


]]