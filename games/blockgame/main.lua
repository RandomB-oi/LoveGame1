local module = {}

module.init = function()
	mainGame = game.new("Block Game")
	blockgameData = datastore:getDatastore("blockgame")

	-- seasonColor = color.from255(232, 83, 19, 255)
	-- seasonColor = color.from255(170, 255, 0, 255)
	seasonColor = color.from255(37, 82, 21, 255)
	

	function mainGame:loadWorld(worldName)
		local gameScene = mainGame:getScene("main-game")
		mainWorld = instance.new("world", gameScene)
		mainWorld.name = worldName
		localPlayer = instance.new("player", gameScene)
		mainWorld.maid:giveTask(localPlayer)
		
		mainWorld.player = localPlayer
		localPlayer.world = mainWorld
	
		local screenWidth = love.graphics.getWidth()
		local blockWidth = mainWorld.cellSize.x
		mainWorld.renderDistance = math.round((screenWidth/blockWidth)/2+1)

		local lastSave = 0
		local saveInterval = 60*1
		mainWorld.maid:giveTask(gameScene.update:connect(function()
			-- local newColor = color.fromHSV((os.clock()*100)%255, 255, 150, 255)

			-- seasonColor.r = newColor.r
			-- seasonColor.g = newColor.g
			-- seasonColor.b = newColor.b
					
			local t = os.clock()
			if t-lastSave>saveInterval then
				lastSave = t
				print("saved")
				mainGame:saveData(worldName)
			end
		end))

		do
			local savedData = blockgameData:getAsync(worldName)
			if savedData then
				local playerData = savedData.playerData
				if playerData then
					localPlayer.position.x = playerData.position.x
					localPlayer.position.y = playerData.position.y
					
					localPlayer.velocity.x = playerData.velocity.x
					localPlayer.velocity.y = playerData.velocity.y
		
					localPlayer.currentItem = playerData.currentItem
					localPlayer.fly = playerData.fly
		
					for i, item in pairs(playerData.toolbar) do
						local newItem
						if item.name then
							newItem = instance.new(item.name or "item", localPlayer, item.name, item.amount, item.extraData)
						end
						localPlayer.toolbar.items[i] = newItem or {}
					end
				end
				local chunkDifferences = savedData.chunkDifferences
				if chunkDifferences then
					mainWorld:setChanges(chunkDifferences)
				end
				if savedData.time then
					mainWorld.time = savedData.time
				end
			end
		end
	end
	
	function mainGame:saveData(worldName)
		if not (localPlayer and mainWorld) then return end
		if not worldName then worldName = mainWorld.name end
		local playerData = {
			position = localPlayer.position,
			velocity = localPlayer.velocity,
		
			toolbar = {},
			currentItem = localPlayer.currentItem,
			fly = localPlayer.fly,
		}

		for i, item in pairs(localPlayer.toolbar.items) do
			playerData.toolbar[i] = {
				name = item.name,
				amount = item.amount,
				extraData = item.extraData,
			}
		end

		local allChanges = {}
		for x, row in pairs(mainWorld.chunks) do
			allChanges[x] = {}
			for y, chunk in pairs(row) do
				if next(chunk.changes) then
					allChanges[x][y] = chunk.changes
				end
			end
			if not next(allChanges[x]) then
				allChanges[x] = nil
			end
		end
		
		blockgameData:setAsync(worldName, {
			playerData = playerData,
			chunkDifferences = allChanges,
			time = mainWorld.time,
		})
	end
end

module.start = function()
	mainGame:setWindowSize(vector2.new(600, 400))

	mainGame:loadWorld("testWorld")
	
	mainWorld:calculateLighting()
end

return module