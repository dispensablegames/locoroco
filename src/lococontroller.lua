local Loco = require("loco")
LocoController = {}

function LocoController:init(world)
	local finishedController = {}
	finishedController.locos_ = {}
	finishedController.locoCount_ = 0
	finishedController.world_ = world
	finishedController.freeId_ = 1
	
	self.__index = self
	setmetatable(finishedController, self)
	
	return finishedController
end

function LocoController:update()
	local currentTime = love.timer.getTime()
	for i, loco in pairs(self.locos_) do
		if currentTime - loco:getCreationTime() > 2 then
			loco:deleteBJoints()
		end
	end
end

function LocoController:createLoco(x, y, size, popDist, t)
	local tab = t or self.locos_
	local loco = Loco:init(self.world_, x, y, size, popDist)
	loco:setId(self.freeId_)
	table.insert(tab, self.freeId_, loco)
	self.freeId_ = self.freeId_ + 1
	self.locoCount_ = self.locoCount_ + 1
end

function LocoController:deleteLoco(loco)
	self.locos_[loco:getId()] = nil
	self.locoCount_ = self.locoCount_ - 1
	loco:delete()
end
	
function LocoController:mergeLocos()
	local newTable = {}
	for i, loco1 in pairs(self.locos_) do
		local loco2 = loco1:getLocoCollision()
		if loco2 then
			local x1, y1 = loco1:getPosition()
			local x2, y2 = loco2:getPosition()
			local newX, newY = averagePoint(x1, x2, y1, y2)
			newX = newX + 30
			local newSize = loco1:getSize() + loco2:getSize()
			self:deleteLoco(loco1)
			self:deleteLoco(loco2)
			self:createLoco(newX, newY, newSize, newSize * -1, newTable)
		end		
	end
	utils.tableAppendFunky(self.locos_, newTable)
end

function LocoController:impulse(x, y)
	for i, loco in pairs(self.locos_) do
		if loco:getJumpability() then
			loco:impulse(x, y)
		end
	end
end

function LocoController:breakApart()
	local newTable = {}
	for i, loco in pairs(self.locos_) do
		if loco:getSize() == 1 then
			utils.tableAppendFunky(newTable, {[loco:getId()]=loco})
		else
			local newLocos = {}
			local x, y = loco:getPosition()
			local donePoints = {}	
			for i=1, loco:getSize() do
				local newX, newY = loco:getSuitablePoint(donePoints, 60, 50)
				self:createLoco(newX, newY, 1, -20, newLocos)
				table.insert(donePoints, {x=newX, y=newY})
			end
			self:deleteLoco(loco)
			utils.tableAppendFunky(newTable, newLocos)
		end
	end
	self.locos_ = newTable
end

function LocoController:deleteRandomLoco()
	for i, loco in pairs(self.locos_) do
		self:deleteLoco(loco)
		return
	end
end

function LocoController:getCameraPosition()
	if self.locoCount_ > 0 then 
		for i,loco in pairs(self.locos_) do
			return loco:getPosition()
		end
	else
		return nil
	end
end

function LocoController:draw()
	for i, loco in pairs(self.locos_) do
		love.graphics.setColor(0, 255, 255)
		loco:draw(false)
		if love.keyboard.isDown("t") then
			love.graphics.setColor(255, 255, 0)
			loco:draw(true)
		end
	end
end

return LocoController