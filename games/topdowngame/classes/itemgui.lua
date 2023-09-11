local module = {}
module.__index = module
module.derives = "classes/instances/classes/gui"

local amountColor = color.new(1,1,1,1)
module.new = function(self)
	self.item = nil
	self.amountLabel = love.graphics.newText(defaultFont, "12")
	local lastAmount
	
	self.maid.draw = self.scene.guiDraw:connect(function()
		if not self:isActive() then return end
		if self.parent then
			self.parent._drawn:wait()
		end
		if self.item and self.item.name then
			local cf = cframe.new(self.renderPosition.x, self.renderPosition.y)
			self.item:render(cf, self.renderSize)

			if self.item.amount ~= lastAmount then
				lastAmount = self.item.amount
				self.amountLabel:set(tostring(lastAmount))
			end
			amountColor:apply()
			local amountSize = vector2.new(self.renderSize.x, self.renderSize.y/2)
			love.graphics.cleanDrawText(self.amountLabel, self.renderPosition+(self.renderSize-amountSize), amountSize, false, "right", "bottom")
		end
		self._drawn:fire()
	end)
	
	return self
end

module.init = function()
	instance.addClass("itemgui", module)
end

return module