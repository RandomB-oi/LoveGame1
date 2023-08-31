local module = {}
module.__index = module

module.new = function(world, data, wx, wy)
	for py, pattern in ipairs(data.pattern) do
		for px = 1, pattern:len() do
			local blockName = data.legend[pattern:sub(px, px)]
			if blockName and blockName ~= "void" then
					local block = world:getBlock(x,y)
					if block then
						block:destroy()
					end
					local x, y = px - data.origin.x + wx, py - data.origin.y + wy

					world:setBlock(x,y, blockName, nil, true)
			end
		end
	end
end

module.init = function()
	instance.addClass("structure", module)
end

return module