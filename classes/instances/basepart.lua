local module = {}
module.__index = module
module.type = "basepart"
module.derives = "classes/instances/instance"

module.new = function(self)
	self.cframe = cframe.new(0, 0, 0)
	self.size = vector2.new(100, 100)
	self.color = color.new(255,255,255,255)
	
	self.maid.draw = self.scene.draw:connect(function()
		love.graphics.push()
		love.graphics.translate(self.cframe.x, self.cframe.y)
		love.graphics.rotate(self.cframe.r)
		self.color:apply()
		love.graphics.rectangle("fill", -self.size.x/2, -self.size.y/2, self.size.x, self.size.y)
		love.graphics.pop()
	end)
	return self
end

module.init = function()
	instance.addClass("basepart", module)
end

return module