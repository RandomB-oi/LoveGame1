local module = {}
module.__index = module

module.new = function(slotCount)
	local self = setmetatable({}, module)
	self.items = {}
	
	for i = 1, slotCount do
		table.insert(self.items, {})
	end
	
	return self
end

function module:countItem(name)
	local total = 0
	for i, itemSlot in pairs(self.items) do
		total = total + itemSlot.amount
	end
	return total
end

function module:takeItem(name, amount)
	for i, item in pairs(self.items) do
		if item.name == name and amount > 0 then
			local amtToRemove = math.clamp(amount, 0, item.amount)
			amount = amount - amtToRemove
			self:removeItem(i, amtToRemove)
		end
	end
end

function module:removeItem(index, amount)
	local item = self.items[index]
	item.amount = item.amount - amount
	if item.amount <= 0 then
		item:destroy()
		self.items[index] = {}
	end
end

function module:giveItem(item)
	for i, itemSlot in pairs(self.items) do
		if itemSlot.name == item.name and itemSlot.extraData == item.extraData then
			local amtToAdd = math.clamp(itemSlot.amount + item.amount, 0, item.stackSize) - itemSlot.amount
			item.amount = item.amount - amtToAdd
			itemSlot.amount = itemSlot.amount + amtToAdd
			if item.amount <= 0 then
				item:destroy()
				break
			end
		end
	end
	for i, itemSlot in pairs(self.items) do
		if not itemSlot.name and item.amount > 0 then
			local amtToAdd = math.clamp(item.amount, 0, item.stackSize)
			item.amount = item.amount - amtToAdd
			local newItem = instance.new(item.className, item.owner, item.name, amtToAdd, item.extraData)
			self.items[i] = newItem
			if newItem then
				newItem.maid.containerRemove = function()
					self.items[i] = {}
				end
			end
		
			if item.amount <= 0 then
				item:destroy()
				break
			end
		end
	end
	if item.amount <=0 then
		return
	end
	return item
end

module.init = function()
	instance.addClass("container", module)
end

return module