local module = {}
module.__index = module

module.new = function(scene)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.scene = scene

	self.chunkSize = 16
	self.blockSize = 64
	self.terminalVelocity = vector2.new(30, 30)

	self.renderDistance = math.ceil(math.max(love.graphics.getDimensions()) / self.blockSize / self.chunkSize / 2)
	
	self.chunks = {}

	self.maid.draw = self.scene.draw:connect(function()
		for x = -self.renderDistance, self.renderDistance, 1 do
			for y = -self.renderDistance, self.renderDistance, 1 do
				local chunk = self:getChunk(x,y, true)
				if chunk then
					chunk:render()
				end
			end
		end
	end)
	
	return self
end

function module:getChunkPosition(x,y)
	return math.floor(x/self.chunkSize), math.floor(y/self.chunkSize)
end

function module:getChunk(x,y, noGenerate)
	local chunk = self.chunks[x] and self.chunks[x][y]

	if not noGenerate and not chunk then
		chunk = instance.new("chunk", x, y)
		chunk.world = self
		self.chunks[x] = self.chunks[x] or {}
		self.chunks[x][y] = chunk
	end

	return chunk
end

function module:getBlock(x,y)
	local chunkX, chunkY = world:getChunkPosition(x,y)
	local chunk = world:getChunk(chunkX, chunkY, true)
	if chunk then
		local blockX, blockY = chunk:toChunkSpace(x,y)
		return chunk:getBlock(blockX, blockY)
	end
end

function module:setBlock(x,y, block)
	local chunkX, chunkY = world:getChunkPosition(x,y)
	local chunk = world:getChunk(chunkX, chunkY, false)
	local blockX, blockY = chunk:toChunkSpace(x,y)
	chunk:setBlock(blockX, blockY, block)
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("world", module)
end

return module