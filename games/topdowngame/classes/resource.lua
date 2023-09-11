local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/tile"

module.new = function(self)
	self.tile = nil
	self.image = nil
	self.collidable = true
	
	return self
end

function module:render(cf, size)
	if self.tile then
		self.tile:render(cf, size)
	end
	instance.getClass("tile").render(self, cf, size)
end

module.init = function()
	instance.addClass("resource", module)
end

return module