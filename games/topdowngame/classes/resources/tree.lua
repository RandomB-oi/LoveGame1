local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/resource"

module.new = function(self)
	self.tile = instance.new("grass")
	self.image = love.graphics.newImage("games/topdowngame/assets/tree.png")
	
	return self
end

module.init = function()
	instance.addClass("tree", module)
end

return module