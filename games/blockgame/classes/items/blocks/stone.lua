local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/stone.png")
	
	return self
end

module.init = function()
	instance.addClass("stone", module)
end

return module