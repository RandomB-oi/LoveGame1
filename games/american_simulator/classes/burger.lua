local module = {}
module.__index = module
module.derives = "games/american_simulator/classes/food"

module.new = function(self)
	self.image = love.graphics.newImage("games/american_simulator/assets/burger.png")

	self.isATotallyHealthyDietForAnAmerican = true
	
	return self
end

module.init = function()
	instance.addClass("burger", module)
end

return module