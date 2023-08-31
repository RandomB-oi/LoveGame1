local module = {}

module.init = function()
	mainGame = game.new("american_simulator game")
end

module.start = function()
	mainGame:setWindowSize(vector2.new(600, 400))
end

return module