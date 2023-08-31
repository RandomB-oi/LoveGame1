local module = {}
module.__index = module

module.new = function(owner, name, amount, extraData)
	local self = setmetatable({}, module)
	self.maid = maid.new()

	self.name = name or "block"
	self.amount = amount or 1
	self.extraData = extraData
	self.owner = owner
	
	self.stackSize = 16
	
	return self
end

function module:removeOne()
	self.amount = self.amount - 1
	if self.amount <= 0 then
		self:destroy()
	end
end

function module:leftClick(mousePosInBlockSpace)

end

function module:rightClick(mousePosInBlockSpace)

end

local mainColor = color.new(1,1,1,1)
function module:render(cf, size)
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
	instance.addClass("item", module)
end

return module