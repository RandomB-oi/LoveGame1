local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/tile"

module.new = function(self)
	self.image = love.graphics.newImage("games/topdowngame/assets/bricks.png")
	
	return self
end

module.init = function()
	instance.addClass("bricks", module)
end

return module