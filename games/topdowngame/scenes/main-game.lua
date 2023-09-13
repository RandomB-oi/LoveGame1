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

	local craftingTable = instance.new("container", 3, 3)
	
	player.data.inventory:giveItem(instance.new("wood", "wood", 25))
	player.data.inventory:giveItem(instance.new("stone", "stone", 25))

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

		local craftOutputFrame = instance.new("image", scene, "craftOutput")
		craftOutputFrame.size = udim2.new(0, 70, 0, 70)
		craftOutputFrame.anchorPoint = vector2.new(0, 0)
		craftOutputFrame.position = udim2.new(0.62, 0, 0.65, 0)
		craftOutputFrame:setImage("games/topdowngame/assets/itemSlot.png")
		craftOutputFrame.active = false
		craftOutputFrame.zIndex = 1
	
		local craftItemFrame = instance.new("itemgui", scene, "icon")
		craftItemFrame.size = udim2.new(0.75, 0, 0.75, 0)
		craftItemFrame.position = udim2.new(0.5, 0, 0.5, 0)
		craftItemFrame.anchorPoint = vector2.new(.5, 0.5)
		craftItemFrame.parent = craftOutputFrame

		local currentDragItem
		craftOutputFrame.clicked:connect(function()
			local craftableRecipe = instance.getClass("item").getRecipe(craftingTable.slots)
			if not craftableRecipe then return end

			if currentDragItem then
				if currentDragItem.name ~= craftableRecipe.craftInfo.name then return end
				if currentDragItem.amount + craftableRecipe.craftInfo.amount > currentDragItem.stackSize then return end
			end
				
			for x, row in pairs(craftingTable.slots) do
				for y, item in pairs(row) do
					if item and item.name then
						item:remove(1)
						if item.destroyed then 
							craftingTable.slots[x][y] = {} 
							craftingTable.changed:fire() 
						end
					end
				end
			end
				
			if currentDragItem then 
				currentDragItem.amount = currentDragItem.amount + craftableRecipe.craftInfo.amount 
			else
				instance.getClass("container").setDragItem(instance.new(
					craftableRecipe.craftInfo.itemClass, 
					craftableRecipe.craftInfo.name, 
					craftableRecipe.craftInfo.amount))
			end
		end)

		craftingTable.changed:connect(function()
			local craftableRecipe = instance.getClass("item").getRecipe(craftingTable.slots)
			if craftItemFrame.item then craftItemFrame.item:destroy() craftItemFrame	.item = nil end
			if craftableRecipe then
				craftItemFrame.item = instance.new(
					craftableRecipe.craftInfo.itemClass, 
					craftableRecipe.craftInfo.name, 
					craftableRecipe.craftInfo.amount)
				craftOutputFrame.active = true
			else
				craftOutputFrame.active = false
			end
		end)
		instance.getClass("container").dragChanged:connect(function(newItem)
			currentDragItem = newItem
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
	local inventoryGui, inventoryFrames = player.data.inventory:createGui(scene)
	inventoryGui.size = udim2.new(1,0,0.65,0)
	
	local craftingGui, craftingFrames = craftingTable:createGui(scene)
	craftingGui.size = udim2.new(0.24, 0, 0.35, 0)
	craftingGui.position = udim2.new(0.5, 0, 1, 0)
	craftingGui.anchorPoint = vector2.new(0.5, 1)

	player.maid.input = scene.inputBegan:connect(function(key, isMouse)
		if isMouse then

		else
			if key == "tab" then
				inventoryGui.active = not inventoryGui.active
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