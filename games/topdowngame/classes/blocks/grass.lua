local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/tile"

module.new = function(self)
	self.image = love.graphics.newImage("games/topdowngame/assets/grass.png")
	-- self.color = color.new(0, 1, 0, 1)
	
	return self
end

module.init = function()
	instance.addClass("grass", module)
end

return module