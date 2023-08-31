local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.color = color.from255(201, 176, 113, 255)
	
	return self
end

module.init = function()
	instance.addClass("planks", module)
end

return module