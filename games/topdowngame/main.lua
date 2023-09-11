local module = {}

module.init = function()
	mainGame = game.new("Some top down game or something idk")
end

module.start = function()
	mainGame:setWindowSize(vector2.new(600, 400))
end

return module