local utils = require("utils")
local LocoController = require("lococontroller")
local Level = require("level")
local ResultScreen = {}

function ResultScreen:init(numLocos, maxLocos, numFlies, maxFlies, time)
	local finishedScreen = {}

	finishedScreen.state = "dropping locos"
	finishedScreen.animationState = 0
	finishedScreen.world = love.physics.newWorld(0, 9.81*16, true)
	finishedScreen.locoController = LocoController:init(finishedScreen.world)

	finishedScreen.numLocos = numLocos
	finishedScreen.maxLocos = maxLocos
	finishedScreen.droppedLocos = 0
	finishedScreen.numFlies = numFlies
	finishedScreen.maxFlies = maxFlies
	finishedScreen.time = time

	finishedScreen.locoDropX = 500
	
	love.graphics.setBackgroundColor(255, 255, 255)
	
	self.__index = self
	setmetatable(finishedScreen, self)

	return finishedScreen
end

function ResultScreen:update(dt)
	local locoInterval = 30

	for i=1, 3 do
		self.world:update(dt)
	end
	self.locoController:update()
	if self.state == "dropping locos" then
		if self.animationState > locoInterval then
			self.locoController:createLoco(self.locoDropX, -50, 1)
			self.droppedLocos = self.droppedLocos + 1
			self.animationState = 0
		end

		self.animationState = self.animationState + 1

		if self.droppedLocos == self.numLocos then
			self.state = "displaying flies"
		end
	end
end

function ResultScreen:draw()

	love.graphics.setColor(0, 0, 0)
	love.graphics.print(self.droppedLocos .. "/" .. self.maxLocos, 100, 100)
	love.graphics.scale(0.50)
	self.locoController:draw()
end

function ResultScreen:mousepressed()
end

function ResultScreen:mousereleased()
end

function ResultScreen:keyreleased(key)
end


return ResultScreen