local Drawing = require("drawing")
local Path = require("path")

local Level = {}

function Level:init(filename)
	local level = {}
	level.drawing = Drawing:init(filename)
	level.hardbodies = {}
	level.pictures = {}

	for i,path in ipairs(level.drawing:getPaths()) do
		if path:getStyle("spawn") then
			local spawnX, spawnY = averagePoints(path:getPoints())
			level.spawnX = spawnX
			level.spawnY = spawnY
		elseif path:getStyle("notphysical") then
			local color = parseColor(path:getStyle("fill"))
			local points = path:getPoints()
			local picture = { color = color, points = points }
			table.insert(level.pictures, picture)
		else
			local points = path:getPoints()
			local avgX, avgY = averagePoints(points)
			shiftPoints(points, avgX, avgY)
			
			local body = love.physics.newBody(world, avgX, avgY, "kinematic")
			if path:getStyle("rotate") then
				body:setAngularVelocity(tonumber(path:getStyle("rotate")))
			end
			local shape = love.physics.newChainShape(true, unpack(points))
			local fixture = love.physics.newFixture(body, shape)
			fixture:setFriction(3) 
			local color = parseColor(path.style.fill)
			local hardbody = { color = color, body = body, shape = shape }
			table.insert(level.hardbodies, hardbody)
		end

	end

	self.__index = self
	setmetatable(level, self)
	return level
end

function parseColor(color)
	local newColor = {}
	for val in string.gmatch(string.sub(color, 2), "..") do
		table.insert(newColor, tonumber(val, 16) / 255)
	end
	return newColor	
end

function Level:draw()
	local pictures = self.pictures
	for i,picture in ipairs(pictures) do
		print("picture")
		love.graphics.setColor(picture.color)
		for j,triangle in ipairs(love.math.triangulate(picture.points)) do
			love.graphics.polygon("fill", triangle)
		end
	end
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

function averagePoints(points)
	local xSum = 0
	local ySum = 0

	for i=1, #points, 2 do
		xSum = xSum + points[i]
		ySum = ySum + points[i + 1]
	end
	return xSum / (#points / 2), ySum / (#points / 2)
end

function shiftPoints(points, x, y)
	for i=1, #points, 2 do
		points[i] = points[i] - x
		points[i + 1] = points[i + 1] - y
	end
end
		

return Level
