local module = {}
module.__index = module
module.derives = "classes/instances/instance"

module.new = function(self)
	self.blocks = {}
	self.changes = {}
	self.x = 0
	self.y = 0
end

function module:getWorldPos(x,y)
	local chunkPosX = self.x * self.world.chunkSize
	local chunkPosY = self.y * self.world.chunkSize
	if not (x and y) then
		return chunkPosX, chunkPosY
	end

	return chunkPosX + x, chunkPosY + y
end

function module:getChunkPos(x,y)
	local chunkPosX, chunkPosY = self:getWorldPos()
	return x - chunkPosX, y - chunkPosY
end

function module:getBlock(x,y, isWorldPos)
	if isWorldPos then
		x,y = self:getChunkPos(x,y)
	end

	return self.blocks[x] and self.blocks[x][y]
end

function module:setBlock(x,y, isWorldPos, blockName, extraData, worldGen, fromChanges)
	-- if blockName == "air" then return end
	if not blockName then blockName = "air" end

	if isWorldPos then
		x,y = self:getChunkPos(x,y)
	end
		
	local has = self:getBlock(x,y)
	if has then has:destroy() end

	if not worldGen then
		self.changes[x] = self.changes[x] or {}
		self.changes[x][y] = {name = blockName, extraData = extraData}
	end
	
	self.blocks[x] = self.blocks[x] or {}
	--owner, name, amount, extraData
	local newBlock = instance.new(blockName, nil, blockName, 1, nil)
	if not newBlock then return end
	
	newBlock.x = x
	newBlock.y = y
	newBlock.maid:giveTask(function()
		self.blocks[x][y] = nil
		self:setBlock(x,y, false, "air", nil, true)
	end)
	newBlock.mined:connect(function()
		self.changes[x] = self.changes[x] or {}
		self.changes[x][y] = {}
	end)
	self.blocks[x][y] = newBlock

	if mainWorld and not worldGen and not fromChanges then
		mainWorld:calculateLighting(self:getWorldPos(x, y))
	end
end

function module:setChanges(changes)
	if not changes then return end
	self.changes = changes
	for x, row in pairs(changes) do
		for y, change in pairs(row) do
			if change and change.name then
				self:setBlock(x,y, false, change.name, change.extraData, false, true)
			else
				local existingBlock = self:getBlock(x,y)
				if existingBlock then
					existingBlock:destroy(true)
				end
			end
		end
	end
end

module.init = function()
	instance.addClass("chunk", module)
end

return module