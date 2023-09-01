local module = {}
module.__index = module
module.type = "color"

module.new = function(r,g,b, a)
	return setmetatable({
		r = r or 1,
		g = g or 1,
		b = b or 1,
		a = a or 1,
	}, module)
end

module.from255 = function(r,g,b,a)
	r=r or 255
	g=g or 255
	b=b or 255
	a=a or 255
	return module.new(r/255, g/255, b/255, a/255)
end

 local function hue2rgb(p, q, t)
	if t < 0   then t = t + 1 end
	if t > 1   then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end

module.fromHSV = function(h, s, l, a)
    local r, g, b

    h = (h / 255)
    s = (s / 100)
    l = (l / 100)

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local q
        if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    if not a then a = 1 end
    return module.new(r, g, b, a)
end

function module:__mul(other)
	return module.new(
		self.r * other.r,
		self.g * other.g,
		self.b * other.b,
		self.a * other.a
	)
end

function module:lerp(other, alpha)
	return module.new(
		math.lerp(self.r, other.r, alpha),
		math.lerp(self.g, other.g, alpha),
		math.lerp(self.b, other.b, alpha),
		math.lerp(self.a, other.a, alpha)
	)
end

function module:apply()
	if config and config.version == "0.10.2" then
		love.graphics.setColor(self.r * 255, self.g * 255, self.b * 255, self.a * 255)
	else
		love.graphics.setColor(self.r, self.g, self.b, self.a)
	end
end

return module