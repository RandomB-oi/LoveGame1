local module = {}
module.__index = module

module.new = function(chunkX, chunkY)
	local self = setmetatable({}, module)
	self.maid = maid.new()

	self.x = chunkX
	self.y = chunkY
	self.blocks = {}
	
	return self
end

function module:render()
	local blockSize = vector2.new(self.world.blockSize, self.world.blockSize)
	for x, row in pairs(self.blocks) do
		for y, block in pairs(row) do
			local wx, wy = self:toWorldSpace(x,y)
			block:render(cframe.new(wx * blockSize.y, wy * blockSize.y), blockSize)
		end
	end
end

function module:toChunkSpace(x,y)
	return x % self.world.chunkSize, y % self.world.chunkSize
end

function module:toWorldSpace(x,y)
	return x + self.x * self.world.chunkSize, y + self.y * self.world.chunkSize
end

function module:getBlock(x, y)
	return self.blocks[x] and self.blocks[x][y]
end

function module:setBlock(x, y, newBlock)
	local hasBlock = self:getBlock(x, y)
	if hasBlock then hasBlock:destroy() end

	self.blocks[x] = self.blocks[x] or {}
	self.blocks[x][y] = newBlock
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("chunk", module)
end

return module