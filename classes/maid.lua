local function doTask(task)
	local t = type(task)
	if t == "table" then
		local f = (task.destroy or task.Destroy or task.disconnect or task.Disconnect or task.release or task.close)
		if f then
			local s,e = pcall(f, task)
			-- if not s and e then print(e) end
		end
	elseif t == "function" then
		local s,e = pcall(task)
		if not s and e then
			print(e)
		end
	-- elseif t == "thread" then
	-- 	local s,e = pcall(coroutine.yield)
	-- 	if not s and e then
	-- 		print(e)
	-- 	end
	end
end

local module = {}
module.type = "maid"
module.__index = function(self, i)
	local modHas = rawget(module,i)
	if modHas then return modHas end

	local selfHas = rawget(self,i)
	if selfHas then return selfHas end

	return self._tasks[i]
end

module.__newindex = function(self, i, v)
	if rawequal(self, module) then
		rawset(module, i, v)
		return 
	end
	
	doTask(self[i])

	rawset(self._tasks, i, v)
end

module.new = function()
	return setmetatable({_tasks={}}, module)
end

function module:giveTask(task)
	table.insert(self._tasks, task)
end

function module:destroy()
	local index, task = next(self._tasks)
	while index and task ~= nil do
		self[index] = nil
		index, task = next(self._tasks)
	end
end

return module