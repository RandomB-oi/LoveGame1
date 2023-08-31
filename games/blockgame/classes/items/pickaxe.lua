local module = {}
module.__index = module
module.derives = "games/blockgame/classes/item"

module.new = function(self)
	self.stackSize = 1

	self.swingSpeed = 1/3
	self.damageType = "dirt"
	self.damage = 5

	self._lastSwing = -math.huge
	
	return self
end

function module:leftClick(mousePosInBlockSpace)
	local t = os.clock()
	if t-self._lastSwing<self.swingSpeed then return end
	self._lastSwing = t
	
	local x,y = math.floor(mousePosInBlockSpace.x), math.floor(mousePosInBlockSpace.y)
	local block = mainWorld:getBlock(x,y)
	if block and block.name ~= "air" then
		self.owner.toolbar:giveItem(block)
		block:destroy()
		-- mainWorld:setBlock(block.x, block.y)
	end
end

module.init = function()
	instance.addClass("pickaxe", module)
end

return module