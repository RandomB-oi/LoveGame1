local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/log.png")
	
	return self
end

module.init = function()
	instance.addClass("log", module)
end

return module