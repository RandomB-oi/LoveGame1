local module = {}
module.__index = module
module.derives = "games/blockgame/classes/items/block"

module.new = function(self)
	self.grasstop = love.graphics.newImage("games/blockgame/assets/grasstop.png")
	self.dirt = love.graphics.newImage("games/blockgame/assets/dirt.png")
	self.grasscolor = seasonColor
	
	return self
end

local white = color.new(1,1,1,1)
local black = color.new(0,0,0,1)
function module:render(cf, size)
	local lightColor = self:getLightColor()
	love.graphics.push()
	love.graphics.translate(cf.x+size.x/2, cf.y+size.y/2)
	love.graphics.rotate(cf.r)

	local c1 = (white*lightColor)
	c1:apply()
	love.graphics.cleanDrawImage(self.dirt, -size/2, size)
	local c2 = (self.grasscolor*lightColor)
	c2:apply()
	love.graphics.cleanDrawImage(self.grasstop, -size/2, size)
	
	love.graphics.pop()
end

module.init = function()
	instance.addClass("grass", module)
end

return module