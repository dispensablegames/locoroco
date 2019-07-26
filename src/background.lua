local Path = require("path")
local Use = require("use")
local UseBatch = require("usebatch")

local utils = require("utils")

local Background = {}

function Background:init(paths, uses, usepaths)
	local background = {}
	background.paths = paths
	background.usebatches = {}

	for i,use in ipairs(uses) do
		local href = use:getHref()
		if not background.usebatches[href] then
			background.usebatches[href] = UseBatch:init(usepaths[href])
		end
		background.usebatches[href]:addUse(use)
	end
	
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
	for id,usebatch in pairs(self.usebatches) do
		usebatch:draw()
	end
end

return Background
