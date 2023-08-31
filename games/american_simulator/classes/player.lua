local module = {}
module.__index = module
module.derives = "classes/instances/instance"

local mainColor = color.new(1,1,1,1)
module.new = function(self)
	self.position = vector2.new(0, 0)
	self.size = vector2.new(50, 50)

	self.walkSpeed = 100

	self.maid.draw = self.scene.draw:connect(function()
		mainColor:apply()
		love.graphics.rectangle("fill", 
			self.position.x, self.position.y, 
			self.size.x, self.size.y
		)
	end)

	self.maid.movement = self.scene.update:connect(function(dt)
		local moveDirection = vector2.new(0, 0)

		if love.keyboard.isDown("w") then
			moveDirection.y = moveDirection.y - 1
		end
		if love.keyboard.isDown("s") then
			moveDirection.y = moveDirection.y + 1
		end
			
		if love.keyboard.isDown("a") then
			moveDirection.x = moveDirection.x - 1
		end
		if love.keyboard.isDown("d") then
			moveDirection.x = moveDirection.x + 1
		end

		if moveDirection.magnitude > 0.01 then
			self.position = self.position + moveDirection.unit * self.walkSpeed * dt
		end
	end)

	self.maid.foodCollection = self.scene.update:connect(function(dt)
		for _, food in pairs(allFoods) do
			local sizeRange = (food.size + self.size)/2
			local posDiff = food.cframe.position - self.position
			posDiff.x = math.abs(posDiff.x)
			posDiff.y = math.abs(posDiff.y)

			if posDiff < sizeRange then
				food:destroy()
			end
		end
	end)
	
	return self
end

module.init = function()
	instance.addClass("player", module)
end

return module