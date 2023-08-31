local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("main-game")
	scene:unpause()
	scene:enable()
	scene.update:connect(function()
		if math.random() < 0.01 then
			local isBad = math.random(1,3) == 1
			local newFood
			if isBad then
				newFood = instance.new("broccy", scene)
			else
				newFood = instance.new("burger", scene)
			end
			local maxX, maxY = love.graphics.getDimensions()
			newFood.cframe = cframe.new(math.random(50, maxX-50), math.random(50, maxY-50))
		end
	end)
end

module.start = function()
	instance.new("player", scene)
	-- instance.new("burger", scene)
end

return module