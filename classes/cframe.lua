local module = {}
module.type = "cframe"
module.__index = function(self,i)
	return classUtil.basic__index(module, self, i, {
		position = function(self)
			return vector2.new(self.x, self.y)
		end,
		up = function(self)
			return vector2.fromAngle(self.r)
		end,
		down = function(self)
			return vector2.fromAngle(self.r + math.pi)
		end,
		right = function(self)
			return vector2.fromAngle(self.r + math.pi/2)
		end,
		left = function(self)
			return vector2.fromAngle(self.r - math.pi/2)
		end,
	})
end

module.new = function(x,y, r)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		r = r or 0
	}, module)
end

function module.lookat(origin, point)
	local diff = point - origin
	return module.new(origin.x, origin.y, math.atan2(diff.y, diff.x)+math.pi/2)
end
	
function module:copy()
	return module.new(self.x, self.y)
end

function module:__add(other)
	return module.new(
		self.x + other.x,
		self.y + other.y,
		self.r
	)
end

function module:__sub(other)
	return module.new(
		self.x - other.x,
		self.y - other.y,
		self.r
	)
end

function module:__mul(other)
	local movedX = self.right * other.x
	local movedY = self.down * other.y
	local r = other.r + self.r

	return module.new(
		self.x + movedX.x + movedY.x,
		self.y + movedX.y + movedY.y,
		r
	)
end

return module