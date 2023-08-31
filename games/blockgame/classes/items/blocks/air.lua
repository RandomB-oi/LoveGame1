local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.collidable = false
	return self
end

module.init = function()
	instance.addClass("air", module)
end

return module