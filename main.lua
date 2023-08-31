typeof = function(value)
	local t = type(value)
	if t == "table" then
		return value.type or t
	end
	return t
end

classUtil = require("utilities.classUtil")
string = require("utilities.string")
math = require("utilities.math")
table = require("utilities.table")
instance = require("utilities.instance")
utilities, _utilitiesOrder = classUtil.recurseRequire("utilities")
classUtil.recurseInit(utilities, _utilitiesOrder)
classUtil.recurseStart(utilities, _utilitiesOrder)

classes, _classOrder = classUtil.recurseRequire("classes")
classUtil.recurseInit(classes, _classOrder)
classUtil.recurseStart(classes, _classOrder)

udim = classes.udim
udim2 = classes.udim2
color = classes.color
vector2 = classes.vector2
cframe = classes.cframe
signal = classes.signal
spring = classes.spring
maid = classes.maid
game = classes.game
thread = classes.thread
datastore = classes.datastore

local games = {"blockgame", "american_simulator", "yard_defence"}
local function loadGame(name)
	local path = "games/"..name
	gameDirectory, order = classUtil.recurseRequire(path)
	classUtil.recurseInit(gameDirectory, order)
	classUtil.recurseStart(gameDirectory, order)
end

mainUpdate = signal.new()
mainDraw = signal.new()

inputBegan = signal.new()
inputEnded = signal.new()
guiInputBegan = signal.new()
guiInputEnded = signal.new()

love.graphics.setLineWidth(1.5)

-- game selection
local preDeterminedIndex = 1

if preDeterminedIndex then
	loadGame(games[preDeterminedIndex])
	print("done loading game")
else
	print("Select a game #")
	for i, v in pairs(games) do
		print(tostring(i).." "..tostring(v))
	end
	local index = tonumber(io.read() or "")
	if index and games[index] then
		print("loading game...")
		loadGame(games[index])
		print("game loaded successfully")
	else
		error("no game selected")
	end
end

-- yields drawing, and input until the game loads
love.update = function(dt)
	local dt = math.clamp(dt, 0, 1/10)
	mainUpdate:fire(dt)
end
love.draw = function()
	mainDraw:fire()
end	

_gameProcessedGobal = false

love.keypressed = function(key)
	guiInputBegan:fire(key, false)
	inputBegan:fire(key, false, _gameProcessedGobal)
	_gameProcessedGobal = false
end
love.keyreleased = function(key)
	guiInputEnded:fire(key, false)
	inputEnded:fire(key, false, _gameProcessedGobal)
end
love.mousepressed = function(_,_,button)
	guiInputBegan:fire(button, true)
	inputBegan:fire(button, true, _gameProcessedGobal)
	_gameProcessedGobal = false
end
love.mousereleased = function(_,_,button)
	guiInputEnded:fire(button, true)
	inputEnded:fire(button, true, _gameProcessedGobal)
end