local Fruit = require("fruit")
local ItemController = require("itemcontroller")
local Drawing = require("drawing")

FruitController = ItemController:init()

function FruitController:init(world)
	local finishedController = {}
	finishedController.items_ = {}
	finishedController.world_ = world
	finishedController.itemsTotal_ = 0
	finishedController.locosToIncrement_ = {}
	finishedController.frames_ = { importFrame("src/assets/fruit.svg"), importFrame("src/assets/fruiteaten.svg")}
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

function FruitController:addFruit(pointsTable)
	self:addItems(pointsTable, Fruit, {self.frames_})
end

function FruitController:update(locoController)
	for i, fruit in pairs(self.items_) do
		local loco = fruit:update()
		if loco then
			local inList = false
			for i, thing in pairs(self.locosToIncrement_) do
				if thing[1]:getId() == loco:getId() then
					thing[2] = thing[2] + 1
					thing[3] = thing[3]  + 10
					inList = true
				end
			end
			if not inList then
				table.insert(self.locosToIncrement_, {loco, 1, 100})
				loco:setTarget(0, 0, "self")
			end
		end
	end

	for i, thing in pairs(self.locosToIncrement_) do
		local loco = thing[1]
		local incAmount = thing[2]
		local count = thing[3]
		if count == 0 then
			if not loco:getDestroyed() then
				locoController:incrementLocoSize(loco, incAmount)
			else
				locoController:incrementRandomLoco(incAmount)
			end
			table.remove(self.locosToIncrement_, i)
		end
		thing[3] = thing[3] - 1
	end
end

return FruitController