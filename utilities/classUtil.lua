local module = {}

module.basic__index = function(module, self, i, functions)
	local modHas = rawget(module, i)
	if modHas then return modHas end
	
	local selfHas = rawget(self, i)
	if selfHas then return modHas end

	if functions[i] then
		return functions[i](self)
	end
end

module.loadModule = function(modToLoad)
	local derivesName = rawget(modToLoad, "derives")
	local derives = derivesName and require(derivesName)
	if derives then
		rawset(modToLoad, "derives", derives)
		setmetatable(modToLoad, derives)
	else
		rawset(modToLoad, "derives", nil)
	end
end

module.recurseRequire = function(directory, requireOrder)
	local tbl = {}
	local requireOrder = requireOrder or {}

	local directories = {}
	local files = {}
	
	for i, fileName in pairs(love.filesystem.getDirectoryItems(directory)) do
		local isDirectory do
			if love.filesystem.getInfo then
				isDirectory = love.filesystem.getInfo(directory.."/"..fileName).type == "directory"
			else
				isDirectory = love.filesystem.isDirectory(directory.."/"..fileName)
			end
		end

		if isDirectory then
			table.insert(directories, {name = fileName, directory = directory.."/"..fileName})
		elseif fileName:find(".lua") then
			local objectName = string.split(fileName, ".")[1]
			local fileDir = directory.."/"..objectName
			table.insert(requireOrder, fileDir)

			local required = require(fileDir)
			rawset(required,"_fileName", objectName)
			tbl[objectName] = required
			module.loadModule(required)
		end
	end

	for _ , info in ipairs(directories) do
		tbl[info.name] = module.recurseRequire(info.directory, requireOrder)
	end
	
	return tbl, requireOrder
end

module.recurseInit = function(tbl, order)
	if order then
		for _, dir in ipairs(order) do
			local module = require(dir)
			local init = module and rawget(module, "init")
			if init then
				init()
			end
		end
		return
	end
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			local init = rawget(v, "init")
			if init then
				init()
			end
			module.recurseInit(v)
		end
	end
end

module.recurseStart = function(tbl, order)
	if order then
		for _, dir in ipairs(order) do
			local module = require(dir)
			local start = module and rawget(module, "start")
			if start then
				start()
			end
		end
		return
	end
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			local start = rawget(v, "start")
			if start then
				start()
			end
			module.recurseStart(v)
		end
	end
end

module.new = function(class, ...)
	local order = {class}
	local parentClass = class
	while true do
		local derives = rawget(parentClass, "derives")
		if derives then
			parentClass = derives
			table.insert(order, parentClass)
		else
			table.remove(order, #order) -- because this is parentClass
			break
		end
	end
	local object = parentClass.new(...)
	for i = #order, 1, -1 do
		local subClass = order[i]
		setmetatable(object, subClass)
		local newMethod = rawget(subClass, "new")
		if newMethod then
			object = newMethod(object) or object
		end
	end
	return object
end

return module