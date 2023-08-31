local module = {}
module.__index = module
module.type = "udim"

module.new = function(scale, offset)
	return setmetatable({
		scale = scale or 0, 
		offset = offset or 0
	}, module)
end

return module