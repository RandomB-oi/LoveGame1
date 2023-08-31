local module = {}
module.__index = module
module.type = "instance"

local function removeFromChildren(parent, self)
	table.remove(oldParent.children, table.find(oldParent.children, self))
end

module.new = function(scene)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.scene = scene
	self.destroying = signal.new()
	self.maid:giveTask(destroying)

	self.parent = nl
	self.children = {}
	local oldParent
	self.maid:giveTask(scene.update:connect(function(dt)
		if self.parent ~= oldParent then
			if oldParent then
				self.maid.parentDestroy = nil
				self.maid.selfDestroy = nil
				removeFromChildren(oldParent, self)
			end
			local newParent = self.parent
			oldParent = newParent
			if newParent then
				table.insert(newParent.children, self)
				self.maid.parentDestroy = newParent.destroying:connect(function()
					self:destroy()
				end)
				self.maid.selfDestroy = self.destroying:connect(function()
					removeFromChildren(newParent, self)
				end)
			end
		end
	end))
	
	return self
end

function module:destroy()
	self.destroying:fire()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("instance", module)
end

return module