local module = {}
module.__index = module
module.derives = "games/blockgame/classes/item"

module.new = function(self)
	self.mined = signal.new()
	self.stackSize = 999
	self.lightLevel = {r=15,g=15,b=15}
	self.collidable = true
	
	return self
end

--[[
https://stackoverflow.com/a/4535188
Each square has a light level from 15 to 0. Each level is 20% less than the level above it. If a square contains a light source it gets the luminosity of that light source, otherwise it gets one less than the brightest neighbor.

Sunlight is special, it suffers no vertical attenuation.
]]

local function applyHighest(base, add)
	base.r = math.max(add.r, base.r)
	base.g = math.max(add.g, base.g)
	base.b = math.max(add.b, base.b)
end
function module:calulateLighting()
	local neighbors = {
		vector2.new(1,0),
		vector2.new(0,1),
		vector2.new(-1,0),
		vector2.new(0,-1),
	}
	if mainWorld.lightingMode == "color" then
		local brightestNeighbor = {r=0,g=0,b=0}
		for _, neighborPosition in pairs(neighbors) do
			local blockPos = neighborPosition+vector2.new(self.x, self.y)
			local block = mainWorld:getBlock(math.round(blockPos.x), math.round(blockPos.y))
			if block and block.name then
				applyHighest(brightestNeighbor, block.lightLevel)
				if block.lightEmit then
					applyHighest(brightestNeighbor, block.lightEmit)
				end
			else
				applyHighest(brightestNeighbor, mainWorld.lightLevel)
			end
		end
		local changed
		for comp, val in pairs(brightestNeighbor) do
			local prev = self.lightLevel[comp]
			self.lightLevel[comp] = math.clamp(val-1, 0, 15)
			if self.lightLevel[comp] ~= prev then
				changed = true
			end
		end
		return changed
	elseif mainWorld.lightingMode == "white" then
		local brightestNeighbor = 0
		for _, neighborPosition in pairs(neighbors) do
			local blockPos = neighborPosition+vector2.new(self.x, self.y)
			local block = mainWorld:getBlock(math.round(blockPos.x), math.round(blockPos.y))
			if block and block.name then
				brightestNeighbor = math.max(block.lightLevel.r, block.lightLevel.g, block.lightLevel.b, brightestNeighbor)
				if block.lightEmit then
					brightestNeighbor = math.max(block.lightEmit.r, block.lightEmit.g, block.lightEmit.b, brightestNeighbor)
				end
			else
				brightestNeighbor = math.max(mainWorld.lightLevel.r, mainWorld.lightLevel.g, mainWorld.lightLevel.b, brightestNeighbor)
			end
		end
		local changed
		local prev = self.lightLevel.r
		local newVal = math.clamp(brightestNeighbor-1, 0, 15)
		self.lightLevel.r = newVal
		self.lightLevel.g = newVal
		self.lightLevel.b = newVal
		return prev ~= newVal
	end
end

function module:getLightColor()
	-- local lightLevel = math.max(self.lightLevel)
	return color.new(self.lightLevel.r/15, self.lightLevel.g/15, self.lightLevel.b/15, 1)
end

local mainColor = color.new(1,1,1,1)
function module:render(cf, size)
	if self.name == "air" then return end
	local blockColor = (self.color or mainColor) * self:getLightColor()
	blockColor:apply()
	love.graphics.push()
	love.graphics.translate(cf.x+size.x/2, cf.y+size.y/2)
	love.graphics.rotate(cf.r)
	if self.image then
		love.graphics.cleanDrawImage(self.image, -size/2, size)
	else
		love.graphics.rectangle("fill", -size.x/2, -size.y/2, size.x, size.y)
	end
	love.graphics.pop()
end

function module:leftClick(mousePosInBlockSpace)
	local x,y = math.floor(mousePosInBlockSpace.x), math.floor(mousePosInBlockSpace.y)
	if self.owner:isIntersecting(vector2.new(x,y), vector2.new(1,1)) then return false end
	
	local block = mainWorld:getBlock(x,y)
	if block and block.name == "air" or not block then
		mainWorld:setBlock(x,y, self.name, self.extraData)
		self:removeOne()
	end
end

function module:destroy(fromChanges)
	if not fromChanges then
		self.mined:fire()
	end
	self.maid:destroy()
end

module.init = function()
	instance.addClass("block", module)
end

return module