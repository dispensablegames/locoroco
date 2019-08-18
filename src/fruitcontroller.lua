local Fruit = require("fruit")
local ItemController = require("itemcontroller")

FruitController = ItemController:init()

function FruitController:init(world)
	local finishedController = {}
	finishedController.items_ = {}
	finishedController.world_ = world
	finishedController.itemsTotal_ = 0
	finishedController.locosToIncrement = {}
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
			local inList = false
			for i, thing in pairs(self.locosToIncrement) do
				if thing[1]:getId() == loco:getId() then
					thing[2] = thing[2] + 1
					thing[3] = thing[3]  + 10
					inList = true
				end
			end
			if not inList then
				table.insert(self.locosToIncrement, {loco, 1, 100})
				loco:setTarget(0, 0, "self")
			end
		end
	end

	for i, thing in pairs(self.locosToIncrement) do
		local loco = thing[1]
		local incAmount = thing[2]
		local count = thing[3]
		if count == 0 then
			locoController:incrementLocoSize(loco, incAmount)
			table.remove(self.locosToIncrement, i)
		end
		thing[3] = thing[3] - 1
	end
end

return FruitController