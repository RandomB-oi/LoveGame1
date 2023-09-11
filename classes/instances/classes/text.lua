local module = {}
module.__index = module
module.derives = "classes/instances/classes/gui"

defaultFont = love.graphics.newFont(64,"normal")

module.new = function(self)
	self:setText("Hello World!")
	self.stretch = false
	self.isCustomFont = false

	self.xAlign = "center"
	self.yAlign = "center"
	self.textScale = 4
	
	self.maid.draw = self.scene.guiDraw:connect(function()
		if not self:isActive() then return end
		if self.parent then
			self.parent._drawn:wait()
		end
		self.color:apply()
		if self.isCustomFont then
				local sizePercent = vector2.new(self.xAlign == "left" and 0 or self.xAlign == "right" and 1 or 0.5, 0.5)
				local renderPosition = self.renderPosition + self.renderSize * sizePercent
				love.graphics.drawCustomText(self.currentText, renderPosition.x, renderPosition.y, self.textScale, self.xAlign)
			else
			love.graphics.cleanDrawText(self.textObject, self.renderPosition, self.renderSize, self.stretch, self.xAlign, self.yAlign)
		end
		self._drawn:fire()
	end)
	
	return self
end

function module:setText(newText)
	if newText == self.currentText then return end
	
	if self.textObject and self.textObject.release then
		self.textObject:release()
	end
	self.textObject = love.graphics.newText(defaultFont, newText)
	self.currentText = newText
end

module.init = function()
	instance.addClass("text", module)
end

return module