local module = {}
module.__index = module

module.new = function(yard, x, y)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.name = "plant"
	self.x = x
	self.y = y
	self.yard = yard
	self.health = 10
	self.maxHealth = 10
	return self
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("plant", module)
end

return module