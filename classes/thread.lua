local module = {}
module.__index = module
module.type = "thread"
-- not really functional, will come back to this later 8/29/23 10:53 am
wait = function(duration)
	local startTime = os.clock()
	repeat until os.clock()-startTime >= duration
	return os.clock()-startTime
end

module.new = function(callback, ...)
	local self = setmetatable({}, module)
	self.closef = nil
	self.thread = coroutine.create(function(...)
		self.closef = coroutine.yield
		callback(...)
	end)
	print("bouta resume")
	-- coroutine.wrap(function(...)
		coroutine.resume(self.thread, ...)
	-- end)()
	print("resumed")
	return self
end

function module:close()
	self.closef()
end

return module