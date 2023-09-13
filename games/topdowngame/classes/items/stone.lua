local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/item"

module.new = function(self)
	self.itemClass = "stone"
	self.stackSize = 10
	self.image = nil
	self.color = color.from255(150, 150, 150)
	
	return self
end

module.init = function()
	instance.addClass("stone", module)
end

module.start = function()
end

return module