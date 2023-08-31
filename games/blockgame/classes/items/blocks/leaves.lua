local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/leaves.png")
	self.color = seasonColor
	self.collidable = false
	return self
end

module.init = function()
	instance.addClass("leaves", module)
end

return module