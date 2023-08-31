local module = {}

module.init = function()
	mainGame = game.new("Garden Defense")
end

module.start = function()
	mainGame:setWindowSize(vector2.new(400, 300))
end

return module