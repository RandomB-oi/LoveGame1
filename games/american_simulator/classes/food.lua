local module = {}
module.__index = module
module.derives = "classes/instances/instance"

allFoods = {}

local mainColor = color.new(1,1,1,1)
module.new = function(self)
	self.cframe = cframe.new(0, 0, 0)
	self.size = vector2.new(75, 75)

	self.maid.draw = self.scene.draw:connect(function()
		mainColor:apply()
		love.graphics.push()
		love.graphics.translate(self.cframe.x, self.cframe.y)
		love.graphics.rotate(self.cframe.r)
		if self.image then
			love.graphics.cleanDrawImage(self.image, vector2.new(0, 0), self.size)
		else
			love.graphics.rectangle("fill", 0, 0, self.size.x, self.size.y)
		end
		love.graphics.pop()
	end)

	table.insert(allFoods, self)
	self.maid:giveTask(function()
		table.remove(allFoods, table.find(allFoods, self))
	end)
	
	return self
end

module.init = function()
	instance.addClass("food", module)
end

return module