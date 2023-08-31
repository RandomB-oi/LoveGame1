local sceneClass = {}
sceneClass.__index = sceneClass
sceneClass.type = "scene"

sceneClass.new = function(game, name)
	local self = setmetatable({}, sceneClass)

	self.name = name
	self.game = game
	
	self.isPaused = false
	self.enabled = true
	
	self.update = signal.new()
	self.draw = signal.new()
	self.guiDraw = signal.new()

	self.guiInputBegan = signal.new()
	self.guiInputEnded = signal.new()
	self.inputBegan = signal.new()
	self.inputEnded = signal.new()
	
	self.maid = maid.new()

	self.maid:giveTask(self.update)
	self.maid:giveTask(self.draw)
	self.maid:giveTask(self.guiDraw)
	self.maid:giveTask(self.guiInputBegan)
	self.maid:giveTask(self.guiInputEnded)
	self.maid:giveTask(self.inputBegan)
	self.maid:giveTask(self.inputEnded)
	
	self.camera = instance.new("camera", self)
	self.maid:giveTask(self.camera)
	
	return self
end

function sceneClass:pause()
	self.isPaused = true
end
function sceneClass:unpause()
	self.isPaused = false
end
function sceneClass:enable()
	self.enabled = true
end
function sceneClass:disable()
	self.enabled = false
end

function sceneClass:destroy()
	self.maid:destroy()
end

local gameClass = {}
gameClass.__index = gameClass
gameClass.type = "game"

gameClass.new = function(gameName)
	local self = setmetatable({
		maid = maid.new(),
		name = gameName,
		scenes = {},

		showFPS = true,
		speed = 1,
	}, gameClass)

	if self.name then
		love.window.setTitle(self.name)
	end

	local lastDeltaTime = 1/60
	self.maid:giveTask(mainUpdate:connect(function(dt)
		dt = dt * self.speed
		for _, scene in pairs(self.scenes) do
			if scene.enabled and not self.isPaused then
				scene.update:fire(dt)
			end
		end
		lastDeltaTime = dt
	end))

	local goodFPS = color.from255(0, 255, 0)
	local okFPS = color.from255(255, 255, 0)
	local stinkyFPS = color.from255(255, 0, 0)
	self.maid:giveTask(mainDraw:connect(function()
		for _, scene in pairs(self.scenes) do
			if scene.enabled then
				love.graphics.push()
				love.graphics.translate(-scene.camera.position.x, -scene.camera.position.y)
				scene.draw:fire()
				love.graphics.pop()
			end
		end
		for _, scene in pairs(self.scenes) do
			if scene.enabled then
				scene.guiDraw:fire()
			end
		end
		if self.showFPS then
			local fps = math.floor(1/lastDeltaTime + 1)
			if fps < 15 then
				stinkyFPS:apply()
			elseif fps < 30 then
				okFPS:apply()
			else
				goodFPS:apply()
			end
			love.graphics.drawCustomText(tostring(fps), 20, 20, 1)
		end
	end))

	self.maid:giveTask(guiInputBegan:connect(function(...)
		for _, scene in pairs(self.scenes) do
			if scene.enabled and not self.isPaused then
				scene.guiInputBegan:fire(...)
			end
		end
	end))
	self.maid:giveTask(guiInputEnded:connect(function(...)
		for _, scene in pairs(self.scenes) do
			if scene.enabled and not self.isPaused then
				scene.guiInputEnded:fire(...)
			end
		end
	end))
	
	self.maid:giveTask(inputBegan:connect(function(...)
		for _, scene in pairs(self.scenes) do
			if scene.enabled and not self.isPaused then
				scene.inputBegan:fire(...)
			end
		end
	end))
	self.maid:giveTask(inputEnded:connect(function(...)
		for _, scene in pairs(self.scenes) do
			if scene.enabled and not self.isPaused then
				scene.inputEnded:fire(...)
			end
		end
	end))
	
	return self
end

function gameClass:setWindowSize(size)
	love.window.setMode(size.x, size.y)
end

function gameClass:getScene(sceneName)
	if self.scenes[sceneName] then 
		return self.scenes[sceneName] 
	end
	local newScene = sceneClass.new(self, sceneName)
	self.scenes[sceneName] = newScene
	return newScene
end

return gameClass