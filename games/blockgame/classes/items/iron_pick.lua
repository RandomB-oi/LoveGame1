local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/pickaxe"

module.new = function(self)
	self.swingSpeed = 1/5
	self.damageType = "dirt"
	self.damage = 5

	self.image = love.graphics.newImage("games/blockgame/assets/pickaxe.png")

	return self
end

module.init = function()
	instance.addClass("iron_pick", module)
end

return module