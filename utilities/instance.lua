local instanceList = {}
local module = {}

function module.new(classname, ...)
	local class = instanceList[classname]
	if class then
		return classUtil.new(class, ...)
	end
	print(classname, "does not exist")
end

function module.addClass(name, class)
	class.className = name
	instanceList[name] = class
end

return module