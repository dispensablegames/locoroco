local Drawing = require("drawing")
local Path = require("path")

local utils = require("utils")

Floaters = {}

function Floaters:init(filename)
	print(filename)
	local floaters = {}

	local drawing = Drawing:init(filename)
	
	floaters.paths = {}
	floaters.active = {}

	for i,path in ipairs(drawing:getPaths()) do
		utils.shiftPoints(path:getPoints(), path:getPoints()[1], path:getPoints()[2])
		table.insert(floaters.paths, path)
	end

	for i,path in ipairs(floaters.paths) do
		for i,point in ipairs(path:getPoints()) do
			print(point)
		end
		print()
	end

	self.__index = self
	setmetatable(floaters, self)

	return floaters
end

function Floaters:update(Camera)
	for i,f in ipairs(self.active) do 
		local cameraX, cameraY = Camera:getTopLeftCorner()
		local x, y = f.body:getPosition()
		if (x > cameraX + love.graphics.getWidth()) then
			f.body:setPosition(cameraX - 100, y)
		end
	end
end
		

function Floaters:createFloater(Camera)
	if #self.active > 6 then
		return
	end
	local randomNum = math.random(#self.paths)	
	local x, y = Camera:getTopLeftCorner()
	x = x - 100
	y = y + math.random(love.graphics.getHeight())
	local vx = math.random(40, 90)
	local vy = math.random(-10, 10)

	local path = self.paths[randomNum]
	local points = path:getPoints()
	local averageX, averageY = utils.averagePoints(points)
	x = x + averageX 
	y = y + averageY
	utils.shiftPoints(points, averageX, averageY)

	local body = love.physics.newBody(world, x, y, "kinematic")
	body:setLinearVelocity(vx, vy)
	body:setAngularVelocity(1)

	local shape = love.physics.newChainShape(true, unpack(points))

	local fixture = love.physics.newFixture(body, shape)
	fixture:setSensor(true)

	local color = utils.parseColor(path.style.fill)

	local f = { color = color, body = body, shape = shape }
	table.insert(self.active, f)
end

function Floaters:draw()
	for i,f in ipairs(self.active) do
		love.graphics.setColor(f.color)
		for j,triangle in ipairs(love.math.triangulate(f.body:getWorldPoints(f.shape:getPoints()))) do
			love.graphics.polygon("fill", triangle)
		end
	end
end
	
return Floaters
