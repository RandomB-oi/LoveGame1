local module = {}
module.__index = module

module.new = function(yard, y)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.name = "zombie"
	self.x = x
	self.y = y
	self.yard = yard
	return self
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("zombie", module)
end

return module