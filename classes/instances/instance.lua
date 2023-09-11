local module = {}
module.__index = module
module.type = "instance"

local function removeFromChildren(parent, self)
	table.remove(self._oldParent.children, table.find(self._oldParent.children, self))
end

module.new = function(scene, name)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.scene = scene
	self.destroying = signal.new()
	self.maid:giveTask(destroying)
	self.active = true

	self.name = name or "frame"
	
	self.parent = nil
	self.children = {}
	self.maid:giveTask(scene.update:connect(function(dt)
		self:updateParent()
	end))
	
	return self
end

function module:findChild(name)
	for _, child in pairs(self.children) do
		if child.name == name then
			return child
		end
	end
end

function module:updateParent()
	if self.parent ~= self._oldParent then
		if self._oldParent then
			self.maid.parentDestroy = nil
			self.maid.selfDestroy = nil
			removeFromChildren(self._oldParent, self)
		end
		local newParent = self.parent
		self._oldParent = newParent
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
end

function module:isActive()
	local parent = self
	while true do
		if not parent then break end
		if not parent.active then return false end
		parent = parent.parent
	end
	return true
end

function module:destroy()
	self.destroying:fire()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("instance", module)
end

return module