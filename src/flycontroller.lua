local Drawing = require("drawing")
local Fly = require("fly")
FlyController = {}

function FlyController:init(world)
	local finishedController = {}
	finishedController.flies_ = {}
	finishedController.world_ = world
	finishedController.fliesTotal_ = nil
	finishedController.fliesCollected_ = 0
	finishedController.frames_ = { importFrame("src/assets/fly1.svg"), importFrame("src/assets/fly2.svg") }
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
	for i=1, #pointsTable/2 do
		local fly = Fly:init(self.world_, pointsTable[2*i - 1], pointsTable[2*i], i, self.frames_)
		table.insert(self.flies_, i, fly)
	end
	self.fliesTotal_ = #pointsTable/2
end

function FlyController:update()
	for i, fly in pairs(self.flies_) do
		local status = fly:update()
		if status == "delete" then
			table.remove(self.flies_, i)
			fly:delete()
			self.fliesCollected_ = self.fliesCollected_ + 1
		end
	end
end

function FlyController:draw()
	for i, fly in pairs(self.flies_) do
		fly:draw()
	end
end

function FlyController:getFlyScore()
	return self.fliesCollected_, self.fliesTotal_
end

return FlyController
