local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/item"

module.new = function(self)
	self.itemClass = "wood"
	self.stackSize = 10
	self.image = nil
	self.color = color.from255(191, 140, 88)
	
	return self
end

module.init = function()
	instance.addClass("wood", module)
end

module.start = function()
end

return module