local module = {}
module.type = "vector2"
module.__index = function(self,i)
	return classUtil.basic__index(module, self, i, {
		magnitude = function(self)
			return math.sqrt(self.x^2 + self.y^2)
		end,
		unit = function(self)
			return self/self.magnitude
		end,
	})
end

local function isNumber(x)
	return type(x) == "number"
end

module.new = function(x, y)
	local self = setmetatable({
		x = x or 0,
		y = y or 0
	}, module)
	return self
end

module.fromAngle = function(angle) -- in radians
	return vector2.new(math.sin(angle), -math.cos(angle))
end

function module:getAngle()
	return math.atan2(-self.y, self.x)
end

function module:copy()
	return module.new(self.x, self.y)
end

function module:__add(other)
	if type(self) == "number" then
		return other + self
	end
	return module.new(self.x + other.x, self.y + other.y)
end

function module:__sub(other)
	if type(self) == "number" then
		return other - self
	end
	return module.new(self.x - other.x, self.y - other.y)
end

function module:__unm(other)
	return module.new(-self.x, -self.y)
end

function module:__mul(other)
	if type(self) == "number" then
		return other * self
	end
	if isNumber(other) then
		return module.new(self.x * other, self.y * other)
	end
	return module.new(self.x * other.x, self.y * other.y)
end

function module:__div(other)
	if type(self) == "number" then
		return other / self
	end
	
	if isNumber(other) then
		return module.new(self.x / other, self.y / other)
	end
	return module.new(self.x / other.x, self.y / other.y)
end

function module:__lt(other)
	return self.x < other.x and self.y < other.y
end

function module:__le(other)
	return self.x <= other.x and self.y <= other.y
end

function module:__eq(other)
	return self.x == other.x and self.y == other.y
end

return module