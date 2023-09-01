-- usage
--[[
local playerData = Datastore:GetDatastore("BobData")

local key = "Bob"
local val = playerData:IncrementAsync(key)

print(val)
]]

function getStr(value, alreadyDoneTables, tabs)
	tabs = tabs or 0
	if type(value) == "string" then
		return "\""..value.."\""
	elseif type(value) == "table" then
		alreadyDoneTables = alreadyDoneTables or {}
		if alreadyDoneTables[value] then
			return "** cyclic table reference **"
		end
		alreadyDoneTables[value] = true
		
		return tableToString(value, alreadyDoneTables, tabs+1)
	else
		return tostring(value)
	end
end

function tableToString(tbl, alreadyDoneTables, tabs)
	local alreadyDoneTables = alreadyDoneTables or {}
	if not next(tbl) then
		return "{}"
	end
	local str = "{\n"
	for index, value in pairs(tbl) do
		local indexString = string.rep("    ", tabs).."["..getStr(index, alreadyDoneTables).."]"
		local valueString = getStr(value, alreadyDoneTables, tabs)
		
		str = str..indexString.." = "..valueString..",\n"
	end
	str = str..string.rep("    ", tabs-1).."}"
	return str
end

function getValue(str)
	return loadstring("return "..str)()
end

--- Check if a file or directory exists in this path
local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

local Datastore = {}
Datastore.__index = Datastore
Datastore.type = "datastore"

local datastoreCache = {}

function Datastore:getDatastore(name)
	if datastoreCache[name] then
		return datastoreCache[name]
	end
	local self = setmetatable({}, Datastore)
	self.name = name
	self.path = "storedData/"..name
	
	pcall(function()
		if not isdir(self.path) then
			os.execute("mkdir " .. self.path)
		end
	end)

	datastoreCache[name] = self
	
	return self
end

function Datastore:setAsync(key, data)
	local str = getStr(data, {})
	local f = io.open(self.path.."/"..key, "w")
	f:write("", str)
	f:close()
end

function Datastore:getAsync(key)
	local f = io.open(self.path.."/"..key, "r")
	if f then
   		local t = f:read("*all")
	    f:close()
	
		return getValue(t)
	end
end

function Datastore:incrementAsync(key, amount)
	local amount = amount or 1
	local hasVal = self:getAsync(key)
	if type(hasVal) ~= "number" then
		hasVal = 0
	end
	local val = (hasVal or 0) + amount
	self:setAsync(key, val)
	
	return val
end

return Datastore