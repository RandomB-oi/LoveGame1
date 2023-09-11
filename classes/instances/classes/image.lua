local module = {}
module.__index = module
module.derives = "classes/instances/classes/gui"

module.new = function(self)
	self:setImage("")
	self.maid.draw = self.scene.guiDraw:connect(function()
		if not self.imageObject then return end
		if not self:isActive() then return end
		if self.parent then
			self.parent._drawn:wait()
		end
		self.color:apply()
		love.graphics.cleanDrawImage(self.imageObject, self.renderPosition, self.renderSize)
		self._drawn:fire()
	end)
	
	return self
end

function module:setImage(newImage)
	if newImage == "" then
		self.imageObject = nil
		return
	end
	self.imageObject = love.graphics.newImage(newImage)
end

module.init = function()
	instance.addClass("image", module)
end

return module