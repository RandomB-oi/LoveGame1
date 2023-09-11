local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("main-game")
	scene:unpause()
	scene:enable()
end

module.start = function()
	world = instance.new("world", scene)
	local player = instance.new("player", scene, world)

	player.data.inventory:giveItem(instance.new("item", "item", 25))

	local dragFrame do
		dragFrame = instance.new("image", scene, "dragFrame")
		dragFrame.size = udim2.new(0, 70, 0, 70)
		dragFrame:setImage("games/topdowngame/assets/itemSlot.png")
		dragFrame.active = false
		dragFrame.zIndex = 50
	
		local itemFrame = instance.new("itemgui", scene, "icon")
		itemFrame.size = udim2.new(0.75, 0, 0.75, 0)
		itemFrame.position = udim2.new(0.5, 0, 0.5, 0)
		itemFrame.anchorPoint = vector2.new(0.5, 0.5)
		itemFrame.parent = dragFrame

		instance.getClass("container").dragChanged:connect(function(newItem)
			if newItem then
				itemFrame.item = newItem
				dragFrame.active = true
			else
				itemFrame.item = nil
				dragFrame.active = false
			end
		end)
		scene.update:connect(function()
			local mx, my = love.mouse.getPosition()
			dragFrame.position = udim2.new(0, mx, 0, my)
		end)
	end
	local gui, frames = player.data.inventory:createGui(scene)
	gui.size = udim2.new(1,0,0.65,0)

	player.maid.input = scene.inputBegan:connect(function(key, isMouse)
		if isMouse then

		else
			if key == "tab" then
				gui.active = not gui.active
			elseif tonumber(key) then
				local index = tonumber(key)
				local slot = index and player.data.inventory.slots[index] and player.data.inventory.slots[index][1]
				
				if slot then
					if index == player.equippedSlot then index = nil end
					player.equippedSlot = index
				end
			end
		end
	end)

	scene.update:connect(function(dt)
		if not (player and world) then return end
		local screenSize = vector2.new(love.graphics.getDimensions())
		local screenPos = (player.position + player.size/2) * world.blockSize - screenSize/2
		-- cameraSpring.Target = screenPos
		scene.camera.position = screenPos -- cameraSpring.Value
	end)
	
	for x = 0, 3 do
		for y = 0, 3 do
			local blockName = math.random(1, 6) == 1 and "tree" or "grass"
			world:setBlock(x,y, instance.new(blockName))
		end
	end
end

return module