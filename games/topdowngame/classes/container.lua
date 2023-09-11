local module = {}
module.__index = module

local dragItem = nil
module.dragChanged = signal.new()

module.new = function(width, height)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.changed = signal.new()
	self.maid:giveTask(self.changed)
	self.slots = {}
	
	for x = 1, width do
		self.slots[x] = {}
		for y = 1, height do
			self.slots[x][y] = {}
		end
	end
	
	return self
end

function module:giveItem(item)
	for y = 1, #self.slots[1] do
		for x = 1, #self.slots do
			local slot = self.slots[x][y]
			if slot.name == item.name and not(slot.extraData or item.extraData) then
				local addAmt = math.clamp(slot.amount + item.amount, 0, item.stackSize) - slot.amount
				slot.amount = slot.amount + addAmt
				item:remove(addAmt)
				if item.destroyed then self.changed:fire() return end
			end
		end
	end
	
	for y = 1, #self.slots[1] do
		for x = 1, #self.slots do
			local slot = self.slots[x][y]
			if not slot.name then
				local addAmt = math.clamp(item.amount, 0, item.stackSize)
				self.slots[x][y] = instance.new(item.itemClass, item.name, addAmt)
				item:remove(addAmt)
				if item.destroyed then self.changed:fire() return end
			end
		end
	end
	-- drop the item or something
	self.changed:fire()
end

function module:createGui(scene)
	local gui = instance.new("gui", scene)
	gui.color = color.new(0,0,0,0)

	local frames = {}

	local function update()
		local width, height = 1 / #self.slots, 1 / #self.slots[1]
		for x, row in pairs(self.slots) do
			for y, slot in pairs(row) do
				local frame = frames[x] and frames[x][y]
				if not frame then
					frame = instance.new("image", scene, tostring(x)..","..tostring(y))
					frame.size = udim2.new(width, -6, height, -6)
					frame.position = udim2.new((x-1)*width, 3, (y-1)*height, 3)
					frame:setImage("games/topdowngame/assets/itemSlot.png")
					frame.parent = gui

					frame.clicked:connect(function(key)
						-- left click > combine / swap
						-- right click > split / place one
						slot = self.slots[x][y]
						if key == 1 then
							if dragItem and (dragItem.name == slot.name and slot.name) and not (slot.extraData or dragItem.extraData) then
								local amtToAdd = math.clamp(slot.amount + dragItem.amount, 0, slot.stackSize)-slot.amount
								dragItem:remove(amtToAdd)
								slot.amount = slot.amount + amtToAdd
								if dragItem.destroyed then dragItem = nil end
							else
								dragItem = dragItem or {}
								self.slots[x][y], dragItem = dragItem, self.slots[x][y]
								if not dragItem.name then dragItem = nil end
							end
						elseif key == 2 then
							if dragItem and ((dragItem.name == slot.name and slot.name) and not (slot.extraData or dragItem.extraData) or not slot.name) then
								if not slot.name then
									slot = instance.new(dragItem.itemClass, dragItem.name, 0)
									self.slots[x][y] = slot
								end
									
								local amtToAdd = math.clamp(slot.amount + 1, 0, slot.stackSize)-slot.amount
								dragItem:remove(amtToAdd)
								slot.amount = slot.amount + amtToAdd
								if dragItem.destroyed then dragItem = nil end
							elseif not dragItem then
								if slot.name then
									local amt = math.ceil(slot.amount/2)
									slot:remove(amt)
									dragItem = instance.new(slot.itemClass, slot.name, amt)
									if slot.destroyed then slot = {} self.slots[x][y] = slot end
								end
							end
						end
						
						self.changed:fire()
						if dragItem and not dragItem.name then
							dragItem = nil
						end

						module.dragChanged:fire(dragItem)
					end)

					local itemFrame = instance.new("itemgui", scene, "icon")
					itemFrame.size = udim2.new(0.75, 0, 0.75, 0)
					itemFrame.position = udim2.new(0.5, 0, 0.5, 0)
					itemFrame.anchorPoint = vector2.new(0.5, 0.5)
					itemFrame.parent = frame

					itemFrame:updateParent() -- manual call because stuff happens in the same frame
					
					frames[x] = frames[x] or {}
					frames[x][y] = frame
				end

				local itemFrame = frame:findChild("icon")
				if itemFrame then
					itemFrame.item = slot
				end
			end
		end
	end
	update()
	self.changed:connect(update)
	return gui, frames
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("container", module)
end

return module