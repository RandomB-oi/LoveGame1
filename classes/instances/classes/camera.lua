local module = {}
module.__index = module
module.derives = "classes/instances/instance"

module.new = function(self)
	self.position = vector2.new(0, 0)
	return self
end

module.init = function()
	instance.addClass("camera", module)
end

return module