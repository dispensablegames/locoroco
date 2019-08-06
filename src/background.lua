local Path = require("path")
local Use = require("use")
local UseBatch = require("usebatch")

local utils = require("utils")

local Background = {}

function Background:init(paths, uses, usepaths)
	local background = {}
	background.paths = paths
	background.pictures = {}

	for i,path in ipairs(paths) do
		local picture = {}
		local imageData = path:toImageData()
		local image = love.graphics.newImage(imageData)
		local x, y = path:getTopLeftCorner()
		picture.image = image
		picture.x = x
		picture.y = y
		table.insert(background.pictures, picture)
	end
	
	background.usebatches = {}
	background.usebatchesSorted = {}

	local index = 1
	for i,use in ipairs(uses) do
		local href = use:getHref()
		if not background.usebatches[href] then
			local usebatch = UseBatch:init(usepaths[href])
			background.usebatches[href] = usebatch
			table.insert(background.usebatchesSorted, usebatch)
		end
		background.usebatches[href]:addUse(use)
	end
	
	self.__index = self
	setmetatable(background, self)

	return background
end

function Background:draw()
	for i,picture in ipairs(self.pictures) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(picture.image, picture.x, picture.y)
	end
	for i,usebatch in ipairs(self.usebatchesSorted) do
		usebatch:draw()
	end
end

return Background
