local module = {}
module.__index = module
module.derives = "classes/instances/classes/gui"

module.new = function(self)
	self.item = nil
	
	self.maid.draw = self.scene.guiDraw:connect(function()
		if self.parent then
			self.parent._drawn:wait()
		end
		if self.item and self.item.name then
			local cf = cframe.new(self.renderPosition.x, self.renderPosition.y)
			self.item:render(cf, self.renderSize)
		end
		self._drawn:fire()
	end)
	
	return self
end

module.init = function()
	instance.addClass("itemgui", module)
end

return module