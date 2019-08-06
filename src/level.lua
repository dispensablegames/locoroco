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
	level.drawing = Drawing:init("src/levels/" .. filename, 96 / 25.4)
	print("drawing initialized")

	level.name = filename

	level.foreground = nil
	level.background = nil

	local foregroundPaths = {}
	local backgroundPaths = {}
	for i,path in ipairs(level.drawing:getPaths()) do
		if path:getStyle("spawn") then
			local spawnX, spawnY = utils.averagePoints(path:getPoints())
			level.spawnX = spawnX
			level.spawnY = spawnY
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
	level.floaters = Floaters:init(world, "src/assets/" .. filename)
	print("floaters initialized")
	level.floaterTimer = 0

	self.__index = self
	setmetatable(level, self)
	return level
end

function Level:getName()
	return self.name
end

function Level:draw()
	love.graphics.setBlendMode("alpha", "premultiplied")
	self.background:draw()
	self.floaters:draw()
	self.foreground:draw()
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
