local Drawing = require("drawing")
local Fly = require("fly")
local ItemController = require("itemcontroller")
FlyController = ItemController:init()

function FlyController:init(world)
	local finishedController = {}
	finishedController.items_ = {}
	finishedController.world_ = world
	finishedController.itemsTotal_ = nil
	finishedController.itemsCollected_ = 0
	finishedController.frames_ = { importFrame("assets/fly1.svg"), importFrame("assets/fly2.svg") }
	self.__index = self
	setmetatable(finishedController, self)

	return finishedController
end

function importFrame(filename)
	local drawing = Drawing:init(filename)
	local image = love.graphics.newImage(drawing:toImageData())
	local height = drawing:getHeight()
	local width = drawing:getWidth()
	return { image = image, height = height, width = width }
end

function FlyController:addFlies(pointsTable)
	self:addItems(pointsTable, Fly, {self.frames_})
end

function FlyController:update()
	for i, fly in pairs(self.items_) do
		local status = fly:update()
		if status == "delete" then
			table.remove(self.items_, i)
			fly:delete()
			self.itemsCollected_ = self.itemsCollected_ + 1
		end
	end
end

function FlyController:getFlyScore()
	return self.fliesCollected_, self.fliesTotal_
end

return FlyController
