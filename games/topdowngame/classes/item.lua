local module = {}
module.__index = module

local recipes = {}

module.new = function(itemName, amount)
	local self = setmetatable({}, module)
	self.maid = maid.new()

	self.itemClass = "item"
	
	self.name = itemName or "item"
	self.amount = amount or 1
	self.stackSize = 10
	self.image = nil
	self.color = color.new(0.5, 0.5, 0.5, 1)
	
	return self
end

function module.getRecipe(container)
	local recipePattern = {}
	local min = vector2.new(math.huge, math.huge)
	local max = vector2.new(-math.huge,-math.huge)

	for x, row in pairs(container) do
		for y, item in pairs(row) do
			if item.name then
				min.x = math.min(min.x, x)
				min.y = math.min(min.y, y)
				max.x = math.max(max.x, x)
				max.y = math.max(max.y, y)
			end
		end
	end
	local size = max-min+vector2.new(1,1)
	for x, row in pairs(container) do
		for y, item in pairs(row) do
			if item.name then
				local nx, ny = x - min.x+1, y - min.y+1
				if nx <= size.x and ny <= size.y and nx > 0 and ny > 0 then
					recipePattern[nx] = recipePattern[nx] or {}
					recipePattern[nx][ny] = item
				end
			end
		end
	end
	
	for i, info in pairs(recipes) do
		local recipe = info.recipe
		local same = true
		if #recipe == size.x then
			for x, row in pairs(recipe) do
				if same and recipePattern[x] and #recipePattern[x] == #row then
					for y, item in pairs(row) do
						if same and not (recipePattern[x] and recipePattern[x][y] and item == recipePattern[x][y].name) then
							same = false
							break
						end
					end
				else
					same = false
				end
			end
		else
			same = false
		end
		if same then return info end
	end
end

function module.addRecipe(pattern, legend, craftInfo)
	local recipe = {}
	for y, str in pairs(pattern) do
		for x = 1, str:len() do
			recipe[x] = recipe[x] or {}
			recipe[x][y] = legend[str:sub(x,x)]
		end
	end
	table.insert(recipes, {
		recipe = recipe,
		craftInfo = craftInfo,
	})
end

function module:remove(amount)
	self.amount = self.amount - amount
	if self.amount <= 0 then
		self:destroy()
	end
end

function module:render(cf, size)
	local color = self.color --* self:getLightColor()
	color:apply()
	love.graphics.push()
	love.graphics.translate(cf.x+size.x/2, cf.y+size.y/2)
	love.graphics.rotate(cf.r)
	if self.image then
		love.graphics.cleanDrawImage(self.image, -size/2, size)
	else
		love.graphics.rectangle("fill", -size.x/2, -size.y/2, size.x, size.y)
	end
	love.graphics.pop()
end

function module:destroy()
	self.destroyed = true
	self.maid:destroy()
end

module.init = function()
	instance.addClass("item", module)
end

return module