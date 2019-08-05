local Fly = require("fly")
FlyController = {}

function FlyController:init(world)
	local finishedController = {}
	finishedController.flies_ = {}
	finishedController.world_ = world
	self.__index = self
	setmetatable(finishedController, self)
	
	return finishedController
end

function FlyController:addFlies(pointsTable)
	for i=1, #pointsTable/2 do
		local fly = Fly:init(self.world_, pointsTable[2*i - 1], pointsTable[2*i], i)
		table.insert(self.flies_, i, fly)
	end
end

function FlyController:update()
	for i, fly in pairs(self.flies_) do
		local status = fly:update()
		if status == "delete" then
			table.remove(self.flies_, i)
			fly:delete()
		end
	end
end

function FlyController:draw()
	for i, fly in pairs(self.flies_) do
		fly:draw()
	end
end

return FlyController