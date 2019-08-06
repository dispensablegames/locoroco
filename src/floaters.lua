local Drawing = require("drawing")
local Path = require("path")

local utils = require("utils")

Floaters = {}

function Floaters:init(world, filename)
	local floaters = {}

	local drawing = Drawing:init(filename)
	
	floaters.paths = {}
	floaters.world = world

	for i,path in ipairs(drawing:getPaths()) do
		local x,y = path:getTopLeftCorner()
		path:setPoints(utils.shiftPoints(path:getPoints(), x, y))
		table.insert(floaters.paths, path)
	end

	floaters.sprites = {}

	for i,path in ipairs(floaters.paths) do
		local imageData = path:toImageData()
		local image = love.graphics.newImage(imageData)
		local sprite = love.graphics.newSpriteBatch(image)
		local center = { path:getCenter() }
		local s = { sprite = sprite, center = center }
		table.insert(floaters.sprites, s)
	end

	floaters.active = {}

	self.__index = self
	setmetatable(floaters, self)

	return floaters
end

function Floaters:update(Camera)
	for i,f in ipairs(self.active) do 
		local x,y = f.body:getPosition()
		local centerX = f.s.center[1]
		local centerY = f.s.center[2]
		f.s.sprite:set(f.id, x - centerX, y - centerY, f.body:getAngle())
	end
end
		

function Floaters:createFloater(Camera)

	local randomNum = math.random(#self.sprites)	
	local s = self.sprites[randomNum]

	local x, y = Camera:getTopLeftCorner()
	x = x - 100
	y = y + math.random(love.graphics.getHeight())
	local vx = math.random(40, 90)
	local vy = math.random(-10, 10)

	local centerX = s.center[1]
	local centerY = s.center[2]
	local id = s.sprite:add(x - centerX, y - centerY)

	local body = love.physics.newBody(self.world, x, y, "kinematic")
	body:setLinearVelocity(vx, vy)
	body:setAngularVelocity(1)

	local f = { s = s, body = body, id = id }
	table.insert(self.active, f)
end

function Floaters:draw()
	for i,s in ipairs(self.sprites) do
		love.graphics.setColor(1,1,1)
		love.graphics.draw(s.sprite)
	end
end
	
return Floaters
