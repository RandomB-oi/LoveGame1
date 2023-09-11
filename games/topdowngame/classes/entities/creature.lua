local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/entity"

module.new = function(self)
	self.position = vector2.new(0, 0)
	self.velocity = vector2.new(0, 0)
	self.size = vector2.new(1, 1)

	self.data.inventory = instance.new("container", 9, 4)
	
	return self
end

module.init = function()
	instance.addClass("player", module)
end

return module