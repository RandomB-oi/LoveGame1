local module = {}

local scene
module.init = function()
	scene = mainGame:getScene("main-menu")
	scene:unpause()
	scene:enable()
end

module.start = function()
	local backdrop = instance.new("gui", scene)
	backdrop.size = udim2.new(.5, -18, 1, -18)
	backdrop.position = udim2.new(0.5, 0, 0.5, 0)
	backdrop.anchorPoint = vector2.new(0.5, 0.5)
	backdrop.color = color.from255(255,255,255,100)

	local resumeButton = instance.new("gui", scene)
	resumeButton.size = udim2.new(1, -18, 0.333, -18)
	resumeButton.position = udim2.new(0.5, 0, 0, 9)
	resumeButton.anchorPoint = vector2.new(0.5, 0)
	resumeButton.color = color.from255(170,255,0,255)
	resumeButton.parent = backdrop
	resumeButton.clicked:connect(function()
		mainGame:getScene("main-menu"):disable()
		mainGame:getScene("main-game"):enable()
		mainGame:getScene("gui"):enable()
	end)

	local resumeText = instance.new("text", scene)
	resumeText.size = udim2.new(1, -6, 1, -6)
	resumeText.position = udim2.new(0.5, 0, 0.5, 0)
	resumeText.anchorPoint = vector2.new(0.5, 0.5)
	resumeText.color = color.from255(0,0,0,255)
	resumeText:setText("Play")
	resumeText.stretch = false
	resumeText.parent = resumeButton


	local saveButton = instance.new("gui", scene)
	saveButton.size = udim2.new(1, -18, 0.333, 0)
	saveButton.position = udim2.new(0.5, 0, .5, 0)
	saveButton.anchorPoint = vector2.new(0.5, .5)
	saveButton.color = color.from255(150,150,150,255)
	saveButton.parent = backdrop

	local saveText = instance.new("text", scene)
	saveText.size = udim2.new(1, -6, 1, -6)
	saveText.position = udim2.new(0.5, 0, 0.5, 0)
	saveText.anchorPoint = vector2.new(0.5, 0.5)
	saveText.color = color.from255(0,0,0,255)
	saveText:setText("Save")
	saveText.stretch = false
	saveText.parent = saveButton
	
	saveButton.clicked:connect(function()
		mainGame:saveData()
	end)
	
	local saveAndQuit = instance.new("gui", scene)
	saveAndQuit.size = udim2.new(1, -18, .333, -18)
	saveAndQuit.position = udim2.new(0.5, 0, 1, -9)
	saveAndQuit.anchorPoint = vector2.new(0.5, 1)
	saveAndQuit.color = color.from255(150,150,150,255)
	saveAndQuit.parent = backdrop
	
	local exitText = instance.new("text", scene)
	exitText.size = udim2.new(1, -6, 1, -6)
	exitText.position = udim2.new(0.5, 0, 0.5, 0)
	exitText.anchorPoint = vector2.new(0.5, 0.5)
	exitText.color = color.from255(0,0,0,255)
	exitText:setText("s quit")
	exitText.stretch = false
	exitText.parent = saveAndQuit

	saveAndQuit.clicked:connect(function()
		mainGame:saveData()
		love.event.quit(0)
	end)
end

return module