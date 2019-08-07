local Drawing = require("drawing")

ItemController = {}

function ItemController:init(world)
	local finishedController = {}
	finishedController.items_ = {}
	finishedController.world_ = world
	finishedController.itemsTotal_ = 0

	self.__index = self
	setmetatable(finishedController, self)

	return finishedController
end

function ItemController:addItems(pointsTable, Object, argTable)
	for i=1, #pointsTable/2 do
		local item = Object:init(self.world_, pointsTable[2*i - 1], pointsTable[2*i], i, unpack(argTable))
		table.insert(self.items_, i, item)
	end
	self.itemsTotal_ = #pointsTable/2
end

function ItemController:update()
	for i, item in pairs(self.items_) do
		item:update()
	end
end

function ItemController:draw()
	for i, item in pairs(self.items_) do
		item:draw()
	end
end


return ItemController
