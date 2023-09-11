local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/entities/creature"

module.new = function(self)
	self.position = vector2.new(0, 0)
	self.velocity = vector2.new(0, 0)
	self.size = vector2.new(0.5, 0.5)

	self.walkSpeed = 4
	
	self.maid.movement = self.scene.update:connect(function(dt)
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
		if moveDir.magnitude > 0.001 then
			moveDir = moveDir.unit
		end
		self.velocity = moveDir * self.walkSpeed
	end)
	
	return self
end

module.init = function()
	instance.addClass("player", module)
end

return module