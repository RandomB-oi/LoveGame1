local module = {}
module.__index = module
module.derives = "classes/instances/instance"

module.new = function(self)
	local color = color.new(255, 255, 255, 255)

	self.size = vector2.new(0.75, 1.75)
	self.position = vector2.new(0, 0)
	self.velocity = vector2.new(0, 0)

	self.walkSpeed = 6
	self.jumpPower = 16.5

	self.fly = false

	self.toolbar = instance.new("container", 9)

	self.toolbar:giveItem(instance.new("iron_pick", self, "iron_pick", 1, nil))
	self.toolbar:giveItem(instance.new("torch", self, "torch", 100, nil))

	self.currentItem = 1
	local m1Down, m2Down
	self.maid:giveTask(self.scene.inputBegan:connect(function(key, isMouse, gp)
		if gp then return end
		-- if not isMouse then return end

		if isMouse then
			if key == 1 then
				m1Down = true
			elseif key == 2 then
				m2Down = true
			end
		else
			local slot = tonumber(key)
			local newTool = slot and self.toolbar.items[slot]
			if newTool then
				if newTool and not newTool.name or slot == self.currentItem then
					slot = nil
				end
				self.currentItem = slot
			end
		end
	end))
	
	self.maid:giveTask(self.scene.inputEnded:connect(function(key, isMouse, gp)
		-- if not isMouse then return end
		
		if isMouse then
			if key == 1 then
				m1Down = false
			elseif key == 2 then
				m2Down = false
			end
		end
	end))

	self.maid.toolLoop = self.scene.update:connect(function()
		local currentItem = self.currentItem and self.toolbar.items[self.currentItem]
		if currentItem and currentItem.name and (m1Down or m2Down) then
			local screenSize = vector2.new(love.graphics.getDimensions())
			local mousePos = vector2.new(love.mouse.getPosition())
			local camPos = self.scene.camera.position
				
			local mousePosInBlockCoords = (camPos + mousePos) / mainWorld.cellSize

			if m1Down then
				currentItem:leftClick(mousePosInBlockCoords)
			elseif m2Down then
				currentItem:rightClick(mousePosInBlockCoords)
			end
		end
	end)
	
	local spacePressed = false
	self.maid.flyToggle = self.scene.inputBegan:connect(function(key)
		if key == "h" then
			self.fly = not self.fly
		end
	end)
	
	self.maid.movement = self.scene.update:connect(function(dt)
		if self.fly then 
			local moveDir = vector2.new(0, 0)
			if love.keyboard.isDown("a") then
				moveDir.x = moveDir.x - 1
			end
			if love.keyboard.isDown("d") then
				moveDir.x = moveDir.x + 1
			end
			if love.keyboard.isDown("w") then
				moveDir.y = moveDir.y - 1
			end
			if love.keyboard.isDown("s") then
				moveDir.y = moveDir.y + 1
			end
			self.position = self.position + moveDir * self.walkSpeed * dt
			return 
		end
			
		local moveDir = vector2.new(0, 0)
		if love.keyboard.isDown("a") then
			moveDir.x = moveDir.x - 1
		end
		if love.keyboard.isDown("d") then
			moveDir.x = moveDir.x + 1
		end

		local spaceDown = not not love.keyboard.isDown("space")
		if spaceDown ~= spacePressed then
			spacePressed = spaceDown
			if spacePressed and not self:canFitPosition(self.position + vector2.new(0, 0.15)) then
				self.velocity.y = -self.jumpPower
			end
		end
		self.velocity.x = moveDir.x * self.walkSpeed
	end)
	
	self.maid.gravity = self.scene.update:connect(function(dt)
		if self.fly then return end
		local world = self.world
		if world then
			self.velocity = self.velocity + world.gravity * dt
		end
	end)

	local physicsFPS = 60 -- i am actually cracked
	self.maid.velocitySolver = self.scene.update:connect(function(dt)
		local smoothing = math.clamp(physicsFPS - (1/dt), 1, physicsFPS)
		for i = 1, smoothing do
			self:solveVelocity(dt/smoothing)
		end
	end)
	
	self.maid.draw = self.scene.draw:connect(function()
		color:apply()
		local cellSize = self.scene.cellSize
		local pos, size = self.position * cellSize, self.size * cellSize
		love.graphics.rectangle("fill", pos.x, pos.y, size.x, size.y)

		-- tool rendering
		local currentItem = self.currentItem and self.toolbar.items[self.currentItem]
		if currentItem and currentItem.name then
				local rot = 0
				if currentItem._lastSwing then
					rot = math.lerp(math.pi/2, 0, math.clamp((os.clock()-currentItem._lastSwing)/currentItem.swingSpeed, 0, 1))
				end
				local cf = cframe.new(
					(self.position.x + self.size.x/2) * self.scene.cellSize.x,
					(self.position.y) * self.scene.cellSize.y
				) * cframe.new(0, 0, rot) * cframe.new(0, -25)
				local size = self.scene.cellSize*1.5
			currentItem:render((cf-size/2), size)
		end
	end)
	return self
end

function module:solveVelocity(dt)
	if self.fly then return end
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
	for _x = -3, 3 do
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

module.init = function()
	instance.addClass("player", module)
end

return module