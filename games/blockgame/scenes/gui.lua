local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("gui")
	scene:unpause()
	scene:disable()

	local toolbar = instance.new("gui", scene)
	toolbar.size = udim2.new(1, -12, .175, -6)
	toolbar.position = udim2.new(0.5, 0, 1, -6)
	toolbar.anchorPoint = vector2.new(0.5, 1)
	toolbar.color = color.from255(0,0,0,0)
	
	local slots = {}
	
	function scene:drawToolbar()
		if not mainWorld then return end
		
		local totalSlotCount = 9
		for i = 1, totalSlotCount do
			if not slots[i] then
				local slotSize = 1/totalSlotCount
				local slot = instance.new("image", scene)
				slot:setImage("games/blockgame/assets/itemSlot.png")
				slot.size = udim2.new(slotSize, 0, 1, 0)
				slot.position = udim2.new((i-1)*slotSize, 0, 0, 0)
				slot.anchorPoint = vector2.new(0, 0)
				slot.color = color.from255(255, 255, 255, 255)
				slot.parent = toolbar

				local insetFrame = instance.new("gui", scene)
				insetFrame.size = udim2.new(0.7, 0, 0.7, 0)
				insetFrame.position = udim2.new(0.5, 0, 0.5, 0)
				insetFrame.anchorPoint = vector2.new(0.5, 0.5)
				insetFrame.color = color.from255(255, 255, 255, 0)
				insetFrame.parent = slot

				local iconFrame = instance.new("itemgui", scene)
				iconFrame.size = udim2.new(1, 0, 1, 0)
				iconFrame.position = udim2.new(0.5, 0, 0.5, 0)
				iconFrame.anchorPoint = vector2.new(0.5, 0.5)
				iconFrame.color = color.from255(255, 255, 255, 255)
				iconFrame.parent = insetFrame

				local numberLabel = instance.new("text", scene)
				numberLabel.size = udim2.new(.35, 0, .3, 0)
				numberLabel.position = udim2.new(0.1, 0, 0.1, 0)
				numberLabel.anchorPoint = vector2.new(0, 0)
				numberLabel.color = color.from255(255,255,255, 255)
				numberLabel.textScale = 0.75
				numberLabel.zIndex = 2
				numberLabel.isCustomFont = true
				numberLabel.xAlign = "left"
				numberLabel.parent = slot
				numberLabel:setText(tostring(i))
				-- local nameLabel = instance.new("text", scene)
				-- nameLabel.size = udim2.new(1, 0, .35, 0)
				-- nameLabel.position = udim2.new(1, 0, 0, 0)
				-- nameLabel.anchorPoint = vector2.new(1, 0)
				-- nameLabel.color = color.from255(255,255,255, 255)
				-- nameLabel.textScale = 0.75
				-- nameLabel.zIndex = 2
				-- nameLabel.isCustomFont = true
				-- nameLabel.parent = insetFrame
				
				local amountLabel = instance.new("text", scene)
				amountLabel.size = udim2.new(1, 0, .35, 0)
				amountLabel.position = udim2.new(0.9, 0, 0.9, 0)
				amountLabel.anchorPoint = vector2.new(1, 1)
				amountLabel.color = color.from255(255,255,255, 255)
				amountLabel.textScale = 0.75
				amountLabel.zIndex = 2
				amountLabel.xAlign = "right"
				amountLabel.isCustomFont = true
				amountLabel.parent = slot

				
				
				slots[i] = {
					iconFrame = iconFrame,
					slotFrame = slot,
					amountLabel = amountLabel,
					-- nameLabel = nameLabel,
					maid = maid.new()
				}
				
				slot.clicked:connect(function()
					if not localPlayer then return end
					local newTool = localPlayer.toolbar.items[i]
					if newTool and not newTool.name or i == localPlayer.currentItem then
						localPlayer.currentItem = nil
						return
					end
					localPlayer.currentItem = i
				end)
			end
			local frame = slots[i]
			local item = mainWorld.player.toolbar.items[i]
			
			if item and item.name then
				frame.iconFrame.item = item
				frame.amountLabel:setText(tostring(item.amount))
				-- frame.nameLabel:setText(tostring(item.name))
			else
				frame.iconFrame.item = nil
				frame.amountLabel:setText("")
				-- frame.nameLabel:setText("")
			end
		end
	end
end

module.start = function()
	scene:drawToolbar()
	scene.update:connect(function()
		scene:drawToolbar()
	end)
end

return module