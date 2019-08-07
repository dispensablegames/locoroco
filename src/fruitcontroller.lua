local Fruit = require("fruit")
local ItemController = require("itemcontroller")

FruitController = ItemController:init()

function FruitController:init(world)
	local finishedController = {}
	finishedController.items_ = {}
	finishedController.world_ = world
	finishedController.itemsTotal_ = 0

	self.__index = self
	setmetatable(finishedController, self)

	return finishedController
end

function FruitController:addFruit(pointsTable)
	self:addItems(pointsTable, Fruit, {})
end

function FruitController:update(locoController)
	for i, fruit in pairs(self.items_) do
		local loco = fruit:update()
		if loco then
			locoController:incrementLocoSize(loco)
		end
	end
end

return FruitController