local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/planks.png")
	
	return self
end

module.init = function()
	instance.addClass("planks", module)
end

return module