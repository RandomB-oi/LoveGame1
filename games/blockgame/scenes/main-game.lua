local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("main-game")
	scene:unpause()
	scene:disable()
end

module.start = function()

	scene.inputBegan:connect(function(key, isMouse)
		if key == "m" then
			mainGame:getScene("main-menu"):enable()
			mainGame:getScene("main-game"):disable()
			mainGame:getScene("gui"):disable()
		end
	end)

	
	-- local newThread = thread.new(function()
	-- 	while true do
	-- 		print("saved")
	-- 		blockgameData:setAsync("playerPos", {
	-- 			x = localPlayer.position.x,
	-- 			y = localPlayer.position.y
	-- 		})
	-- 		wait(1)
	-- 	end
	-- end)

	-- localPlayer.toolbar:giveItem(instance.new("iron_pick", localPlayer, "iron_pick", 2, nil))

	-- local cameraSpring = spring.new(vector2.new())
	-- cameraSpring.Speed = 50
	-- cameraSpring.Damper = 1
	scene.update:connect(function(dt)
		if not (localPlayer and mainWorld) then return end
		local screenSize = vector2.new(love.graphics.getDimensions())
		local screenPos = localPlayer.position * mainWorld.cellSize - screenSize/2
		-- cameraSpring.Target = screenPos
		scene.camera.position = screenPos -- cameraSpring.Value
	end)
end

return module