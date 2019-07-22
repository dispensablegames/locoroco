local Path = require("path")

local utils = require("utils")

local Background = {}

function Background:init(paths)
	local background = {}
	background.paths = paths
	
	self.__index = self
	setmetatable(background, self)

	return background
end

function Background:draw()
	for i,path in ipairs(self.paths) do
		love.graphics.setColor(utils.parseColor(path:getStyle("fill")))
		for j,triangle in ipairs(love.math.triangulate(path:getPoints())) do
			love.graphics.polygon("fill", triangle)
		end
	end
end

return Background
