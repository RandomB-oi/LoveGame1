local module = {}
module.__index = module

module.new = function(owner, name, amount, extraData)
	local self = setmetatable({}, module)
	self.maid = maid.new()

	self.name = name or "block"
	self.amount = amount or 1
	self.extraData = extraData
	self.light = {r=15,g=15,b=15}
	
	return self
end

function module:getLightColor()
	return color.new(self.light.r/15, self.light.g/15, self.light.b/15)
end

local function applyHighest(base, add)
	base.r = math.max(add.r, base.r)
	base.g = math.max(add.g, base.g)
	base.b = math.max(add.b, base.b)
end

local mainColor = color.new(1,1,1,1)
function module:render(cf, size)
	local color = (self.color or mainColor) * self:getLightColor()
	(self.color or mainColor):apply()
	love.graphics.push()
	love.graphics.translate(cf.x+size.x/2, cf.y+size.y/2)
	love.graphics.rotate(cf.r)
	if self.image then
		love.graphics.cleanDrawImage(self.image, -size/2, size)
	else
		love.graphics.rectangle("fill", -size.x/2, -size.y/2, size.x, size.y)
	end
	love.graphics.pop()
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("tile", module)
end

return module