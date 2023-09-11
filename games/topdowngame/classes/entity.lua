local module = {}
module.__index = module

module.new = function(scene, world)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.scene = scene
	self.world = world

	self.position = vector2.new(0, 0)
	self.velocity = vector2.new(0, 0)
	self.size = vector2.new(1, 1)

	self.data = {}
	
	local physicsFPS = 60 -- i am actually cracked
	self.maid.velocitySolver = self.scene.update:connect(function(dt)
		local smoothing = math.clamp(math.round(physicsFPS - (1/dt)), 1, physicsFPS)
		for i = 1, smoothing do
			self:solveVelocity(dt/smoothing)
		end
	end)

	local mainColor = color.new(1,1,1,1)
	self.maid.draw = self.scene.draw:connect(function()
		local size = self.size * self.world.blockSize
		local pos = self.position * self.world.blockSize
		local cf = cframe.new(pos.x, pos.y)
			
		local color = (self.color or mainColor) --* self:getLightColor()
		color:apply()
		love.graphics.push()
		love.graphics.translate(cf.x+size.x/2, cf.y+size.y/2)
		love.graphics.rotate(cf.r)
		if self.image then
			love.graphics.cleanDrawImage(self.image, -size/2, size)
		else
			love.graphics.rectangle("fill", -size.x/2, -size.y/2, size.x, size.y)
		end
		love.graphics.pop()
	end)
	
	return self
end

function module:solveVelocity(dt)
	local world = self.world
	if world then
		self.velocity.x = math.clamp(self.velocity.x, -world.terminalVelocity.x, world.terminalVelocity.x)
		self.velocity.y = math.clamp(self.velocity.y, -world.terminalVelocity.y, world.terminalVelocity.y)
		
		local pos = self.position:copy()
		local newPos = pos + self.velocity * dt

		local canXAxis = self:canFitPosition(vector2.new(newPos.x, pos.y))
		if canXAxis then
			pos.x = newPos.x
			self.position.x = pos.x
		else
			self.position.x = pos.x
			self.velocity.x = 0
		end
			
		local canYAxis = self:canFitPosition(vector2.new(pos.x, newPos.y))
		if canYAxis then
			pos.y = newPos.y
			self.position.y = pos.y
		else
			self.position.y = pos.y
			self.velocity.y = 0
		end
		
		self.position.x = math.round(self.position.x*100)/100
		self.position.y = math.round(self.position.y*100)/100
	end
end

function module:isIntersecting(blockPosition, blockSize, playerPosition)
	local playerSize = self.size
	local playerCenter = (playerPosition or self.position) + playerSize/2
	
	local blockCenter = blockPosition + blockSize/2

	local posDiff = blockCenter - playerCenter
	local posDiffABS = vector2.new(math.abs(posDiff.x), math.abs(posDiff.y))
	
	local sizeRange = (playerSize + blockSize)/2
	
	return posDiffABS < sizeRange
end

function module:canFitPosition(position)
	for _x = -2, 2 do
		for _y = -2, 2 do
			local bx, by = math.round(position.x+_x), math.round(position.y+_y)
			local blockPos = vector2.new(bx,by)
			
			local block = self.world:getBlock(bx, by)
			if block and block.collidable then
				if self:isIntersecting(blockPos, vector2.new(1,1), position) then
					return false
				end
			end
		end
	end
	return true
end	

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("entity", module)
end

return module