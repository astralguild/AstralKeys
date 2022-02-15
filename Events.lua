AstralEvents = CreateFrame('FRAME', 'AstralEvents')
AstralEvents.dtbl = {}

-- Creates new event object
-- @param f Function to be called on event
-- @param name Name for the function for identification
-- @return Event object with method to be called on event fire
function AstralEvents:NewObject(f, name)
	local obj = {}

	obj.name = name or 'anonymous'
	obj.method = f

	return obj
end

-- Registers function to an event
-- @param event Event that is fired when function is to be called
-- @param f Function to be called when event is fired
-- @param name Name of function, used as an identifier
function AstralEvents:Register(event, f, name)
	if self:IsRegistered(event, name) then return end -- Event already registered with same name, bail out
	local obj = self:NewObject(f, name)

	if not self.dtbl[event] then 
		self.dtbl[event] = {}
		AstralEvents:RegisterEvent(event)
	end
	self.dtbl[event][name] = obj
end

-- Unregisters function from being called on event
-- @param event Event the object's method is to be removed from
-- @name The name of the object to be removed
function AstralEvents:Unregister(event, name)
	local objs = self.dtbl[event]
	if not objs then return end
	objs[name] = nil
	if next(objs) == nil then
		self.dtbl[event] = nil
		self:UnregisterEvent(event)
	end
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

-- Gets function bound to event
-- @param event Event to be queried
-- @param handler Object name to be retrieved
-- @return function The function pertaining to the given handler for said event
function AstralEvents:GetRegisteredFunction(event, handler)
	local objs = self.dtbl[event]
	if not objs then return end

	if objs[handler] then
		return objs[handler].method
	else
		return nil
	end
end

-- On event handler passes arguements onto methods to each function
-- @param event Event that was fired
-- @param ... Arguments for said event
function AstralEvents:OnEvent(event, ...)
	local objs = self.dtbl[event]
	if not objs then return end
	for _, obj in pairs(objs) do
		obj.method(...)
	end
end

AstralEvents:SetScript('OnEvent', AstralEvents.OnEvent)