local _, e = ...

local akEvents = CreateFrame('FRAME')

akEvents:SetScript("OnEvent", function(self, event, ...)
		akEvents[event](...)
end)

function e.RegisterEvent(event, func)
	akEvents:RegisterEvent(event)
	akEvents[event] = function(...)
	func(...)
	end
end

function e.UnregisterEvent(event)
	akEvents:UnregisterEvent(event)
	akEvents[event] = nil
end

function e.IsEventRegistered(event)
	if akEvents[event] then return true
	else
		return false
	end
end

local Events = {}
Events.__index = Events
WoWEvents = CreateFrame('FRAME', 'WoWEvents')
WoWEvents.tbl = {}

-- Creates new event object
-- @param f Function to be called on event
-- @param name Name for the function for identification
-- @return Event object with method to be called on event fire

function Events:NewEvent(f, name)
	local obj = {}

	obj.name = name or 'nil'
	obj.method = f

	return obj
end

-- Registers function to an event
-- @param event Event that is fired when function is to be called
-- @param f Function to be called when event is fired
-- @param name Name of function, used as an identifier

function Events:Register(event, f, name)
	local obj = self:NewEvent(f, name)

	if not self.tbl[event] then 
		self.tbl[event] = {}
		WoWEvents:RegisterEvent(event)
	 end
	table.insert(self.tbl[event], obj)
end

-- Unregisters function from being called on event
-- @param event Event the object's method is to be removed from
-- @name The name of the object to be removed

function Events:Unregister(event, name)
	local objs = self.tbl[event]
	if not objs then return end
	for id, obj in pairs(objs) do
		if obj.name == name then
			objs[id] = nil
			break
		end
	end
end

-- Checks to see if an object is registered for an event
-- @param event The event the object is to be called on
-- @param name The name of the object that is to be checked
-- @return True or false if the object is bound to an event

function Events:IsRegistered(event, name)
	local objs = self.tbl[event]
	if not objs then return false end

	for key, obj in pairs(objs) do
		if obj.name == name then
			return true
		end
	end

	return false
end

-- On event handler
-- @param event Event that was fired
-- @param ... Arguments for said event

function Events:OnEvent(event, ...)
	local objs = self.tbl[event]
	if not objs then return end
	for k, obj in pairs(objs) do
		obj.method(...)
	end
end

-- Mixin the contents from Event's to WoWEvents
for k,v in pairs(Events) do
	if type(v) == 'function' and WoWEvents[k] == nil then
		WoWEvents[k] = v
	end
end

local function abc( ... )
	local chan = select(9, ...)
	if chan ~= 'bittieTest' then return end
	print('abc', ...)
	WoWEvents:Unregister('CHAT_MSG_CHANNEL', 'abc')
end

local function def(...)
	local chan = select(9, ...)
	if chan ~= 'bittieTest' then return end
	print('def')
	if not WoWEvents:IsRegistered('CHAT_MSG_CHANNEL', 'abc') then
		print('not registered')
		WoWEvents:Register('CHAT_MSG_SAY', abc, 'abc')
	end
end

WoWEvents:Register('CHAT_MSG_CHANNEL', abc, 'abc')
WoWEvents:Register('CHAT_MSG_CHANNEL', def, 'TEST')

WoWEvents:SetScript('OnEvent', Events.OnEvent)
