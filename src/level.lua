local Drawing = require("drawing")
local Path = require("path")
local Floaters = require("floaters")
local Foreground = require("foreground")
local Background = require("background")

local Level = {}

local utils = require("utils")

function Level:init(filename)
	local level = {}
	level.drawing = Drawing:init(filename)

	level.foreground = nil
	level.background = nil

	local foregroundPaths = {}
	local backgroundPaths = {}

	for i,path in ipairs(level.drawing:getPaths()) do
		if path:getStyle("spawn") then
			local spawnX, spawnY = utils.averagePoints(path:getPoints())
			level.spawnX = spawnX
			level.spawnY = spawnY
		elseif path:tagged("background") then
			table.insert(backgroundPaths, path)
		else
			table.insert(foregroundPaths, path)
		end
	end

	level.foreground = Foreground:init(foregroundPaths)
	level.background = Background:init(backgroundPaths)

	level.floaters = Floaters:init("levels/assets.svg")

	level.floaterTimer = 0

	self.__index = self
	setmetatable(level, self)
	return level
end

function Level:draw()
	self.background:draw()
	self.floaters:draw()
	self.foreground:draw()
end

function Level:update(dt, Camera)

	if self.floaterTimer > 2 then
		self.floaters:createFloater(Camera)
		self.floaterTimer = 0
	else
		self.floaterTimer = self.floaterTimer + 1 * dt
	end

	self.floaters:update(Camera)

	self.floaters:update(Camera)

end

return Level
