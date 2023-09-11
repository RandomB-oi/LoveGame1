local module = {}
module.__index = module

module.new = function(itemName, amount)
	local self = setmetatable({}, module)
	self.maid = maid.new()

	self.itemClass = "item"
	
	self.name = itemName or "item"
	self.amount = amount or 1
	self.stackSize = 10
	self.image = nil
	self.color = color.new(0.5, 0.5, 0.5, 1)
	
	return self
end

function module:remove(amount)
	self.amount = self.amount - amount
	if self.amount <= 0 then
		self:destroy()
	end
end

function module:render(cf, size)
	local color = self.color --* self:getLightColor()
	color:apply()
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
	self.destroyed = true
	self.maid:destroy()
end

module.init = function()
	instance.addClass("item", module)
end

return module