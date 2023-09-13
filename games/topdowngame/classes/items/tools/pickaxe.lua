local module = {}
module.__index = module
module.derives = "games/topdowngame/classes/item"

module.new = function(self)
	self.itemClass = "pickaxe"
	self.stackSize = 1
	self.image = nil
	self.color = color.from255(150, 0, 0)
	
	return self
end

module.init = function()
	instance.addClass("pickaxe", module)
end

module.start = function()
	module.addRecipe(
		{
			"sss",
			"_w_",
			"_w_",
		}, 
		{
			s="stone",
			w="wood",
		}, 
		{
			name="pickaxe",
			amount=1,
			itemClass="pickaxe"
		})
end

return module