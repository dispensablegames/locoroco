local Loco = require("loco")
LocoController = {}

function LocoController:init(world)
	local finishedController = {}
	finishedController.locos_ = {}
	finishedController.locoCount_ = 0
	finishedController.world_ = world
	finishedController.freeId_ = 1
	local ahogeDrawing = Drawing:init("src/assets/ahoge1.svg")
	local ahogeImage = love.graphics.newImage(ahogeDrawing:toImageData())
	finishedController.ahogeSmall = { image = ahogeImage, width = ahogeDrawing:getWidth(), height = ahogeDrawing:getHeight() }
	ahogeDrawing = Drawing:init("src/assets/ahoge2.svg")
	ahogeImage = love.graphics.newImage(ahogeDrawing:toImageData())
	finishedController.ahogeBig = { image = ahogeImage, width = ahogeDrawing:getWidth(), height = ahogeDrawing:getHeight() }
	
	self.__index = self
	setmetatable(finishedController, self)
	
	return finishedController
end

function LocoController:getLocoCount()
	return self.locoCount_
end

function LocoController:checkLocoCollision()
	for i, loco in pairs(self.locos_) do
		if loco:getLocoCollision() then
			return true
		end
	end
	return false
end

function LocoController:update()
	local currentTime = love.timer.getTime()
	for i, loco in pairs(self.locos_) do
		if currentTime - loco:getCreationTime() > 2 then
			loco:deleteBJoints()
		end
	end
end

function LocoController:createLoco(x, y, size, shapeOverride, t, vx, vy, w)
	local tab = t or self.locos_

	local ahoge = self.ahogeSmall
	if size > 1 then
		ahoge = self.ahogeBig
	end

	local loco = Loco:init(self.world_, x, y, size, ahoge, shapeOverride)

	local linearX = vx or 0
	local linearY = vy or 0
	local angular = w or 0

	loco:setId(self.freeId_)
	table.insert(tab, self.freeId_, loco)
	self.freeId_ = self.freeId_ + 1
	self.locoCount_ = self.locoCount_ + 1
	loco:setAngularVelocity(angular)
	loco:setLinearVelocity(linearX, linearY)
end

function LocoController:incrementLocoSize(loco)
	local size = loco:getSize()
	local radius = loco:getRadius()
	local x, y = loco:getPosition()
	local vx, vy = loco:getLinearVelocity()
	local w = loco:getAngularVelocity()
	self:deleteLoco(loco)
	self:createLoco(x, y, size + 1, -2*radius/3, self.locos_, vx, vy, w)
	
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
			local table1 = loco1:getRectCenters()
			local table2 = loco2:getRectCenters()
			for i, element in ipairs(table2) do
				table.insert(table1, element)
			end
		
			local newTable = utils.jenkins(table1)

			local newX, newY = utils.averagePoints(newTable)

			local newSize = loco1:getSize() + loco2:getSize()
			self:deleteLoco(loco1)
			self:deleteLoco(loco2)
			self:createLoco(newX, newY, newSize, newTable, self.locos_, 0, 0, 0)
			
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

function LocoController:setSpringValues(damping, frequency)
	for i, loco in pairs(self.locos_) do
		loco:setSpringValues(damping, frequency)
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
				local newX, newY = loco:getSuitablePoint(donePoints, 30, 50)
				self:createLoco(newX, newY, 1, -30, newLocos)
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

function LocoController:incrementRandomLoco()
	for i, loco in pairs(self.locos_) do
		self:incrementLocoSize(loco)
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
	local pointTable = {}
	for i, loco in pairs(self.locos_) do
		love.graphics.setColor(0, 255, 255)
		loco:draw(false)
		if love.keyboard.isDown("t") then
			love.graphics.setColor(255, 255, 0)
			loco:draw(true)
		end
		local locoTable = loco:getRectCenters()
		for i, thing in ipairs(locoTable) do
			table.insert(pointTable, thing)
		end
	end
	local jenkinsTable = utils.jenkins(pointTable)
	table.insert(jenkinsTable, jenkinsTable[1])
	table.insert(jenkinsTable, jenkinsTable[2])
	if #self.locos_ > 0 then
		love.graphics.line(unpack(jenkinsTable))
	end
end

return LocoController
