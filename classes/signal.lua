local module = {}
module.__index = module
module.type = "signal"
	
module.new = function()
	return setmetatable({}, module)
end

function module:connect(callback, order)
	local connection = {
		order = order or 0,
		_callback = callback,
		disconnect = function(connection)
			table.remove(self, table.find(self, connection))
		end,
	}
	connection.Disconnect = connection.disconnect
	table.insert(self, connection)
	return connection
end

function module:once(callback)
	local connection connection = self:connect(function(...)
		connection:Disconnect()
			
		coroutine.wrap(callback)(...)
	end)
end

function module:wait()
	local thread = coroutine.running()
	self:once(function(...)
		coroutine.resume(thread, ...)
	end)
	return coroutine.yield()

	-- local returned
	-- self:once(function(...)
	-- 	returned = {...}
	-- end)
	-- while not returned do end
	-- return unpack(returned)
end

local unknownOrder = 99999
function module:fire(...)
	local orderedConnections = {}
	
	for _, connection in pairs(self) do
		if not orderedConnections[connection.order or unknownOrder] then
			orderedConnections[connection.order or unknownOrder] = {}
		end
		table.insert(orderedConnections[connection.order], connection)
	end
	
	for order, list in pairs(orderedConnections) do
		for _, connection in ipairs(list) do
			coroutine.wrap(connection._callback)(...)
		end
	end
end

function module:destroy()
	local index, task = next(self)
	while index and task ~= nil do
		task:disconnect()
		index, task = next(self)
	end
end

return module