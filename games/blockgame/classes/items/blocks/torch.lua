local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.image = love.graphics.newImage("games/blockgame/assets/torch.png")
	self.lightEmit = {r=15,g=8,b=0}
	self.collidable = false

	-- mainWorld:calculateLighting(self.x, self.y)
	
	return self
end

module.init = function()
	instance.addClass("torch", module)
end

return module