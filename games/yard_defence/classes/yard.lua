local module = {}
module.__index = module

module.new = function(scene, collumns, rows)
	local self = setmetatable({}, module)
	self.maid = maid.new()
	self.scene = scene
	self.size = vector2.new(100,100)
	self.slots = {}
	for x = 1, collumns do
		self.slots[x] = {}
		for y = 1, rows do
			self.slots[x][y] = {}
		end
	end

	local grassColor = color.from255(170, 255, 0, 255)
	local ligherColor = color.from255(0, 0, 0, 25)
	self.maid.draw = scene.draw:connect(function()
		grassColor:apply()
		love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)

		local cellWidth = self.size.x/collumns
		local cellHeight = self.size.y/rows

		ligherColor:apply()
		for x = 1, collumns do
			if x % 2 == 0 then
				love.graphics.rectangle("fill", (x-1)*cellWidth, 0, cellWidth, self.size.y)
			end
		end
		for y = 1, rows do
			if y % 2 == 0 then
				love.graphics.rectangle("fill", 0, (y-1)*cellHeight, self.size.x, cellWidth)
			end
		end
	end)
	
	return self
end

function module:setPlant(x,y, plantName)
	local newPlant = instance.new(plantName, self, x, y)
	self.slots[x][y] = newPlant
end

function module:destroy()
	self.maid:destroy()
end

module.init = function()
	instance.addClass("yard", module)
end

return module