local module = {}
module.__index = module
module.derives = "classes/instances/instance"

local structureData = require("games/blockgame/structures")

local dayPhaseData = {
	{time = 0, color = {r=0,g=0,b=2}, skyColor = color.from255(0,0,0)},
	{time = 5, color = {r=2,g=2,b=2}, skyColor = color.from255(15, 5, 25)},
	{time = 7, color = {r=8,g=8,b=8}, skyColor = color.from255(40, 20, 90)},
	{time = 10, color = {r=15,g=15,b=15}, skyColor = color.from255(70, 160, 255)},
	{time = 15, color = {r=15,g=15,b=15}, skyColor = color.from255(70, 160, 255)},
	{time = 17, color = {r=8,g=8,b=8}, skyColor = color.from255(40, 20, 90)},
	{time = 19, color = {r=2,g=2,b=2}, skyColor = color.from255(15, 5, 25)},
	{time = 24, color = {r=0,g=0,b=2}, skyColor = color.from255(0,0,0)},
}

module.new = function(self)
	self.chunks = {}
	self.origin = cframe.new(0, 0, 0)
	self.cellSize = vector2.new(40, 40)
	self.gravity = vector2.new(0, 50)
	self.chunkSize = 32
	self.terminalVelocity = vector2.new(20, 75)
	self.renderDistance = 10
	-- self.changes = {}

	-- self.lightLevel = {r=15,g=15,b=15} -- 0 to 15
	self.lightLevel = {r=2,g=2,b=2}
	self.lightingMode = "color"
	-- self.lightingMode = "white"
	self.time = 12

	local dayLength = 60*24
	
	self.maid.update = self.scene.update:connect(function(dt)
		self.scene.cellSize = self.cellSize
		-- self.time = (self.time + (dt * (24/dayLength))) % 24

		-- local prevLight, currentLight
		-- for i = 2, #dayPhaseData do
		-- 	if dayPhaseData[i].time >= self.time and dayPhaseData[i-1].time <= self.time then
		-- 		prevLight = dayPhaseData[i-1]
		-- 		currentLight = dayPhaseData[i]
		-- 	end
		-- end
		-- if prevLight and currentLight then
		-- 	local alpha = (self.time - prevLight.time) / (currentLight.time - prevLight.time)
		-- 	self.lightLevel.r = math.round(math.lerp(prevLight.color.r, currentLight.color.r, alpha))
		-- 	self.lightLevel.g = math.round(math.lerp(prevLight.color.g, currentLight.color.g, alpha))
		-- 	self.lightLevel.b = math.round(math.lerp(prevLight.color.b, currentLight.color.b, alpha))
		-- 	local skyColor = prevLight.skyColor:lerp(currentLight.skyColor, alpha)

		-- 	if config and config.version == "0.10.2" then
		-- 		love.graphics.setBackgroundColor(skyColor.r * 255, skyColor.g * 255, skyColor.b * 255)
		-- 	else
		-- 		love.graphics.setBackgroundColor(skyColor.r, skyColor.g, skyColor.b)
		-- 	end
		-- end
	end)
	self.maid.draw = self.scene.draw:connect(function()
		local origin = self.player and self.player.position or vector2.new(0, 0)
		local rx, ry = math.round(origin.x), math.round(origin.y)

		local renderDistance = self.renderDistance
		for _x = -renderDistance, renderDistance, 1 do
			for _y = -renderDistance, renderDistance, 1 do
				local x, y = rx+_x,ry+_y
				local block = self:getBlock(x,y)
				if block and block.name ~= "air" then
					block:render(self.origin * cframe.new(
						block.x*self.cellSize.x, 
						block.y*self.cellSize.y), 
					self.cellSize)
				end
			end
		end
	end)


	local surfaceLevel = 3
	local worldFloor = 50
	local maxHeight = -50
	local width = 200

	local seed = 100 -- 10, 100
	local treeRNG = love.math.newRandomGenerator()
	treeRNG:setSeed(seed)
	local dungeonRNG = love.math.newRandomGenerator()
	dungeonRNG:setSeed(seed^2)
	local grassRNG = love.math.newRandomGenerator()
	grassRNG:setSeed(seed)
	local freq, amp = 0.049, 25
	local highestBlocks = {}
	for x = -width, width, 1 do
		local noise = love.math.noise(x*freq, seed*freq) * amp
		local highest = math.round(surfaceLevel+noise)
		for y = worldFloor, highest, -1 do
			local blockName = "dirt"
			if y == highest then
				highestBlocks[x] = y
				blockName = "grass"
			elseif y > highest+grassRNG:random(2,8) then
				blockName = "stone"
			end
			self:setBlock(x, y, blockName, nil, true)
		end
	end
	for x = -width, width, 1 do
		for y = maxHeight, worldFloor, 1 do
			if not self:getBlock(x,y) then
				self:setBlock(x,y,"air", nil, true)
			end
		end
	end

	for i = 1, 50 do
		local randomX = treeRNG:random(-width, width)
		instance.new("structure", self, structureData.tree, randomX, highestBlocks[randomX]-1)
	end
	
	for i = 1, 5 do
		local randomX = dungeonRNG:random(-width, width)
		instance.new("structure", self, structureData.dungeon, randomX, highestBlocks[randomX]-1)
	end
	
	return self
end

function module:calculateLighting(rx, ry)
	local lightingBlocks = {}

	local totalcalculations = 0
	local leftOff
	local function calculate()
		local changed
		local modifiedCount = 0
		while modifiedCount < 1000 do
			local i, block = next(lightingBlocks, leftOff)
			leftOff = i
			if not (i and block) then 
				leftOff = nil
				print("was nil, stop it")
				break 
			end

			modifiedCount = modifiedCount + 1
			if block:calulateLighting() then
				changed = true
			end
		end
		return changed
	end
	
	if rx and ry then
		local beginTime = os.clock()
		local lightingCalculationDistance = 15
		for _x = -lightingCalculationDistance, lightingCalculationDistance, 1 do
			for _y = -lightingCalculationDistance, lightingCalculationDistance, 1 do
				local x, y = rx+_x,ry+_y
				local block = self:getBlock(x,y)
				if block then
					table.insert(lightingBlocks, block)
					block.lightLevel.r = 0
					block.lightLevel.g = 0
					block.lightLevel.b = 0
				end
			end
		end
		print("took",os.clock()-beginTime,"seconds to load")
		
		coroutine.wrap(function()
			while true do
				if not calculate() then
					print(totalcalculations)
					break
				end
			end	
		end)()
	else
		-- for x, row in pairs(self.blocks) do
		-- 	for y, block in pairs(row) do
		-- 		table.insert(lightingBlocks, block)
		-- 	end
		-- end
		local beginTime = os.clock()
		local i = 0
		local conn conn = self.scene.update:connect(function()
			i = i + 1
			-- if i % 10 ~= 0 then return end
			if not calculate() then	
				print("took",os.clock()-beginTime,"seconds to load")
				conn:disconnect()
			end
		end)
	end
end

function module:setChanges(allChanges)
	for x, row in pairs(allChanges) do
		for y, change in pairs(row) do
			local chunk = self:getChunk(x,y)
			chunk:setChanges(changes)
		end
	end
end

function module:getChunk(x,y, dontGenerate)
	local chunkX = x - x % self.chunkSize
	local chunkY = y - y % self.chunkSize

	local chunk = self.chunks[chunkX] and self.chunks[chunkX][chunkY]

	if not chunk then
		if dontGenerate then return end
		local newChunk = instance.new("chunk", self.scene)
		self.maid:giveTask(newChunk)
		self.chunks[chunkX] = self.chunks[chunkX] or {}
		self.chunks[chunkX][chunkY] = newChunk
		newChunk.world = self
		chunk = newChunk
	end

	return chunk
end

function module:getBlock(x,y)
	local chunk = self:getChunk(x,y)

	return chunk:getBlock(x,y, true)
end

function module:setBlock(x,y, ...)
	local chunk = self:getChunk(x,y)

	chunk:setBlock(x,y,true,...)
end

module.init = function()
	instance.addClass("world", module)
end

return module