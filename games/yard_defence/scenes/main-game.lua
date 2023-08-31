local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("main-game")
	scene:unpause()
	scene:enable()
end

module.start = function()
	local yard = instance.new("yard", scene, 7,5)
	--400 300
	yard.size = vector2.new(350,250)

	local loadoutGui = instance.new("gui", scene)
	loadoutGui.size = udim2.new(0, 350, 0, 50)
	loadoutGui.position = udim2.new(0, 0, 1, 0)
	loadoutGui.anchorPoint = vector2.new(0, 1)
	loadoutGui.color = color.new(0.75, 0.5, 0.25, 1)

	local loadoutSize = 7
	local cellWidth = 1/loadoutSize
	for i = 1, loadoutSize do
		local button = instance.new("gui", scene)
		button.size = udim2.new(cellWidth, 0, 1, 0)
		button.position = udim2.new((i-1)*cellWidth, 0, 0, 0)
		button.anchorPoint = vector2.new(0, 0)
		button.color = color.new(0, 0, 0, 0)
		button.parent = loadoutGui
		if i % 2 == 0 then
			button.color.a = 0.1
		end
	end
end

return module