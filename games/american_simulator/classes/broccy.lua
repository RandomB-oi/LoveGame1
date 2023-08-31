local module = {}
module.__index = module
module.derives = "games/american_simulator/classes/food"

module.new = function(self)
	self.image = love.graphics.newImage("games/american_simulator/assets/broccy.png")

	self.veryBadForTheAmericanDiet = true
	
	return self
end

module.init = function()
	instance.addClass("broccy", module)
end

return module