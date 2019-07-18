local Drawing = require("drawing")
local Path = require("path")

local Level = {}

function Level:init(filename)
	local level = {}
	level.drawing = Drawing:init(filename)
	level.hardbodies = {}

	for i,path in ipairs(level.drawing:getPaths()) do
		local body = love.physics.newBody(world, 0, 0, "static")
		local shape = love.physics.newChainShape(true, unpack(path:getPoints()))
		local fixture = love.physics.newFixture(body, shape)
		fixture:setFriction(3) 
		local color = parseColor(path.style.fill)
		local hardbody = { color = color, body = body, shape = shape }
		table.insert(level.hardbodies, hardbody)
	end

	self.__index = self
	setmetatable(level, self)
	return level
end

function parseColor(color)
	local newColor = {}
	print(color)
	for val in string.gmatch(string.sub(color, 2), "..") do
		table.insert(newColor, tonumber(val, 16) / 255)
		print(tonumber(val, 16))
	end
	print()
	return newColor	
end

function Level:draw()
	local hardbodies = self.hardbodies
	for i,hardbody in ipairs(hardbodies) do
		love.graphics.setColor(255, 0, 0)
		local points = { hardbody.body:getWorldPoints(hardbody.shape:getPoints()) }
		table.remove(points, #points)
		table.remove(points, #points)
		love.graphics.setColor(hardbody.color)
		for j,triangle in ipairs(love.math.triangulate(hardbody.body:getWorldPoints(hardbody.shape:getPoints()))) do
			love.graphics.polygon("fill", triangle)
		end
	end
end

return Level
