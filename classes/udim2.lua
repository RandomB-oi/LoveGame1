local module = {}
module.__index = module
module.type = "udim2"

module.new = function(xscale, xoffset, yscale, yoffset)
	return setmetatable({
		x = udim.new(xscale, xoffset),
		y = udim.new(yscale, yoffset),
	}, module)
end

module.fromScale = function(x,y)
	return module.new(x, 0, y, 0)
end
module.fromOffset = function(x,y)
	return module.new(0, x, 0, y)
end

function module:calculate(size)
	return vector2.new(
		size.x * self.x.scale + self.x.offset, 
		size.y * self.y.scale + self.y.offset
	)
end

return module