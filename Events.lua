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

AstralEvents = CreateFrame('FRAME', 'AstralEvents')
AstralEvents.dtbl = {}

-- Creates new event object
-- @param f Function to be called on event
-- @param name Name for the function for identification
-- @return Event object with method to be called on event fire

function AstralEvents:NewObject(f, name)
	local obj = {}

	obj.name = name or 'nil'
	obj.method = f

	return obj
end

-- Registers function to an event
-- @param event Event that is fired when function is to be called
-- @param f Function to be called when event is fired
-- @param name Name of function, used as an identifier

function AstralEvents:Register(event, f, name)
	if self:IsRegistered(event, name) then return end
	local obj = self:NewObject(f, name)

	if not self.dtbl[event] then 
		self.dtbl[event] = {}
		AstralEvents:RegisterEvent(event)
	end
	self.dtbl[event][name] = obj
	--table.insert(self.dtbl[event], obj)
end

-- Unregisters function from being called on event
-- @param event Event the object's method is to be removed from
-- @name The name of the object to be removed

function AstralEvents:Unregister(event, name)
	local objs = self.dtbl[event]
	if not objs then return end
	objs[name] = nil
end

-- Checks to see if an object is registered for an event
-- @param event The event the object is to be called on
-- @param name The name of the object that is to be checked
-- @return True or false if the object is bound to an event

function AstralEvents:IsRegistered(event, name)
	local objs = self.dtbl[event]
	if not objs then return false end

	if objs[name] then
		return true
	else
		return false
	end
end

-- On event handler
-- @param event Event that was fired
-- @param ... Arguments for said event

function AstralEvents:OnEvent(event, ...)
	local objs = self.dtbl[event]
	for k,v in pairs(objs) do
		print(k, v)
	end
	if not objs then return end
	for k, obj in pairs(objs) do
		obj.method(...)
	end
end

AstralEvents:SetScript('OnEvent', AstralEvents.OnEvent)