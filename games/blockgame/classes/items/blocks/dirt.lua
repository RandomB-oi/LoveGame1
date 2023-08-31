local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/dirt.png")
	
	return self
end

module.init = function()
	instance.addClass("dirt", module)
end

return module