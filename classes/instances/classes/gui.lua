local module = {}
module.__index = module
module.derives = "classes/instances/instance"

module.new = function(self)
	self._updated = signal.new()
	self.maid:giveTask(self._updated)
	self._drawn = signal.new()
	self.maid:giveTask(self._drawn)
	
	self.anchorPoint = vector2.new(0, 0)
	self.position = udim2.new(0, 0, 0, 0)
	self.size = udim2.new(0, 100, 0, 100)
	self.color = color.from255(255, 255, 255, 255)
	self.zIndex = 1
	
	self.renderPosition = vector2.new(0, 0)
	self.renderSize = vector2.new(0, 0)


	self.clicked = signal.new()
	self.maid:giveTask(self.scene.guiInputBegan:connect(function(key, isMouse)
		if isMouse and self:isHovering() then
			if key == 1 then
				_gameProcessedGobal = true
				self.clicked:fire()
			end
		end
	end))
	
	self.maid:giveTask(self.scene.update:connect(function(dt)
		local relativeSize
		local relativePosition
		if self.parent then
			self.parent._updated:wait()
			relativeSize = self.parent.renderSize
			relativePosition = self.parent.renderPosition
		else
			relativeSize = vector2.new(love.graphics.getDimensions())
			relativePosition = vector2.new(0,0)
		end
		
		self.renderSize = self.size:calculate(relativeSize)
		self.renderPosition = relativePosition + self.position:calculate(relativeSize) - self.renderSize * self.anchorPoint
		
		self._updated:fire()
	end))
	self.maid.draw = self.scene.guiDraw:connect(function()
		self.maid.draw.order = self.zIndex
		if self.parent then
			self.parent._drawn:wait()
		end
		self.color:apply()
		love.graphics.rectangle("fill", self.renderPosition.x, self.renderPosition.y, self.renderSize.x, self.renderSize.y)
	
		self._drawn:fire()
	end)
	
	return self
end

function module:isHovering()
	local mousePos = vector2.new(love.mouse.getPosition())
	local min = self.renderPosition
	local max = min + self.renderSize

	return mousePos > min and mousePos < max
end

module.init = function()
	instance.addClass("gui", module)
end

return module