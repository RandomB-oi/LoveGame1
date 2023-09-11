local instanceList = {}
local module = {}

function module.new(classname, ...)
	local class = instanceList[classname]
	if class then
		return classUtil.new(class, ...)
	end
	print(classname, "does not exist", debug.traceback())
end

function module.addClass(name, class)
	class.className = name
	instanceList[name] = class
end

function module.getClass(name)
	return instanceList[name]
end

return module