local Drawing = require("drawing")
local Path = require("path")
local Floaters = require("floaters")
local Foreground = require("foreground")
local Background = require("background")

local Level = {}

local utils = require("utils")

function Level:init(world, filename)
	local level = {}
	print("initializing drawing...")
	level.drawing = Drawing:init("levels/" .. filename, 96 / 25.4)
	print("drawing initialized")

	level.name = filename

	level.foreground = nil
	level.background = nil

	level.flyPositions = {}
	level.fruitPositions = {}
	level.spawnX = nil
	level.spawnY = nil
	level.gameEndRectangle = nil
	level.zoomOutAreas = {}

	local foregroundPaths = {}
	local backgroundPaths = {}
	for i,path in ipairs(level.drawing:getPaths()) do
		if path:getStyle("meta") then
			if path:getStyle("meta") == "spawn" then
				local spawnX, spawnY = utils.averagePoints(path:getPoints())
				level.spawnX = spawnX
				level.spawnY = spawnY
			elseif path:getStyle("meta") == "gameend" then
				level.gameEndRectangle = path:getPoints()
			elseif path:getStyle("meta") == "zoomout" then
				table.insert(level.zoomOutAreas, path:getPoints())
			elseif path:tagged("flies") then
				local x, y = utils.averagePoints(path:getPoints())
				table.insert(level.flyPositions, x)
				table.insert(level.flyPositions, y)
			elseif path:tagged("fruits") then
				local x, y = utils.averagePoints(path:getPoints())
				table.insert(level.fruitPositions, x)
				table.insert(level.fruitPositions, y)
			end				
		elseif path:tagged("objects") then

		elseif path:tagged("background") then
			table.insert(backgroundPaths, path)
		else
			table.insert(foregroundPaths, path)
		end
	end

	local backgroundUses = {}
	local backgroundUsePaths = {}
	for i,use in ipairs(level.drawing:getUses()) do
		if use:tagged("background") then
			table.insert(backgroundUses, use)
			backgroundUsePaths[use:getHref()] = level.drawing:getPath(use:getHref())
		end
	end

	print("initializing foreground...")
	level.foreground = Foreground:init(world, foregroundPaths, level.drawing:getWidth(), level.drawing:getHeight())
	print("initializing background...")
	level.background = Background:init(backgroundPaths, backgroundUses, backgroundUsePaths)
	print("initializing floaters...")
	level.floaters = Floaters:init(world, "assets/" .. filename)
	print("floaters initialized")
	level.floaterTimer = 0

	self.__index = self
	setmetatable(level, self)
	return level
end

function Level:getFlyPositions()
	return self.flyPositions
end

function Level:getFruitPositions()
	return self.fruitPositions
end

function Level:getName()
	return self.name
end

function Level:drawForeground()
	love.graphics.setBlendMode("alpha", "premultiplied")
	self.foreground:draw()
	self.foreground:drawSecretWalls()
end

function Level:drawBackground()
	love.graphics.setBlendMode("alpha", "premultiplied")
	self.background:draw()
	self.floaters:draw()
end

function Level:update(dt, Camera)

	if self.floaterTimer > 1 then
		self.floaters:createFloater(Camera)
		self.floaterTimer = 0
	else
		self.floaterTimer = self.floaterTimer + 1 * dt
	end

	self.floaters:update(Camera)
end

function Level:getForeground()
	return self.foreground
end

return Level
