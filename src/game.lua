local Camera = require("camera")
local Level = require("level")
local Loco = require("loco")
local FlyController = require("flycontroller")
local LocoController = require("lococontroller")
local FruitController= require("fruitcontroller")
local Game = {}


function Game:init(filename)
	local game = {}
	local world = love.physics.newWorld(0, 9.81*16, true)
	game.world = world
	game.level = Level:init(world, filename)
	game.gravAngle = 0
	game.maxAngle = 0.4
	game.jumpStr = 0
	game.locos = {}
	game.flyController = FlyController:init(world)
	game.locoController = LocoController:init(world)
	game.fruitController = FruitController:init(world)
	love.graphics.setBackgroundColor(255, 255, 255)
	game.secondsPassed = 0
	game.backgroundColor = 1

	game.flyController:addFlies(game.level:getFlyPositions())
	game.fruitController:addFruit(game.level:getFruitPositions())

	game.finishedLocoCount = 0
	game.maxLocoCount = 20
	game.gameEndCount = 100
	game.endRect = {} 
	game.endRect.shape = love.physics.newPolygonShape(game.level.gameEndRectangle)
	game.endRect.body = love.physics.newBody(world, x, y, "static")
	game.endRect.fixture = love.physics.newFixture(game.endRect.body, game.endRect.shape)
	game.endRect.fixture:setSensor(true)
	game.endRect.fixture:setUserData({name="endrect"})

	self.__index = self
	setmetatable(game, self)


	return game
end

function Game:update(dt)
	for i=1, 3 do
		self.world:update(dt)
	end

	self.level:update(dt, Camera)

	self.flyController:update()
	self.locoController:update()
	self.fruitController:update(self.locoController)

	self.backgroundColor = self.backgroundColor + 0.05

	self.finishedLocoCount = 0
	for i, contact in ipairs(self.endRect.body:getContacts()) do
		local fixture1, fixture2 = contact:getFixtures()
		local name1 = fixture1:getUserData().name
		local name2 = fixture2:getUserData().name
		if name1 == "circle" or name2 == "circle" then
			self.finishedLocoCount = self.finishedLocoCount + 1
		end
	end
	if self.finishedLocoCount > 0 then
		self.gameEndCount = self.gameEndCount - 1
	end

	if self.gameEndCount <= 0 then
		return {"ResultScreen", {self.locoController:getLocosCollected(), 20, self.flyController:getFlyScore(), 0}}
	end
	if love.keyboard.isDown("c") and self.locoController:checkLocoCollision() then	
		self.secondsPassed = self.secondsPassed + 1 * dt
		self.locoController:setSpringValues(1.5, 2)
		if self.secondsPassed > 0.5 then
			self.secondsPassed = 0
			self.locoController:mergeLocos()
		end
	end
	
 	if love.keyboard.isDown("right") and love.keyboard.isDown("left") then
		if self.jumpStr < 30 then
			self.jumpStr = self.jumpStr + 2
		end
	elseif love.keyboard.isDown("right") then
 	 	if self.gravAngle < self.maxAngle then
			self.gravAngle = self.gravAngle + 0.015
			Camera:setRotation(self.gravAngle)
			self.world:setGravity(math.sin(self.gravAngle)*9.81*16, math.cos(self.gravAngle)*9.81*16)
		end
	elseif love.keyboard.isDown("left") then
		if self.gravAngle > - self.maxAngle then
			self.gravAngle = self.gravAngle - 0.015
			Camera:setRotation(self.gravAngle)
			self.world:setGravity(math.sin(self.gravAngle)*9.81*16, math.cos(self.gravAngle)*9.81*16)
		end
	elseif love.keyboard.isDown("f") then
	
	end

end

function Game:draw()
	love.graphics.print(self.locoController.locosCollected_, 100, 100)
	love.graphics.setBackgroundColor(self.backgroundColor, self.backgroundColor, self.backgroundColor)
	if self.locoController:getCameraPosition() then
		local x, y = self.locoController:getCameraPosition()
		Camera:set(x, y)
	else
		Camera:set(self.level.spawnX, self.level.spawnY)
	end

	self.level:drawBackground()	
	love.graphics.setBlendMode("alpha", "alphamultiply")
	
	self.locoController:draw()

	self.fruitController:draw()
	self.flyController:draw()

	self.level:drawForeground()
	
	local collected, total = self.flyController:getFlyScore()
	love.graphics.setColor(0, 0, 0)

	Camera:unset()
end

function Game:keyreleased(key)
	local locos = self.locos
	local world = self.world
	local level = self.level
	if key == "1" then
		self.locoController:createLoco(level.spawnX, level.spawnY, 1, 0)
	elseif key == "d" then
		self.locoController:deleteRandomLoco()
	elseif key == "c" then
		self.secondsPassed = 0
	elseif key == "p" then
		self.locoController:breakApart()
		self.backgroundColor = 0
	elseif key == "right" or key == "left" then

		self.locoController:impulse(0, -self.jumpStr*10)
		self.jumpStr = 0

	elseif key == "up" then
		Camera.scaleX = Camera.scaleX * 1.1
	elseif key == "down" then
		Camera.scaleX = Camera.scaleX * 0.9
	elseif key == "u" then
		self.locoController:incrementRandomLoco(1)
	end
end

function Game:mousereleased()
end

function Game:mousepressed()
end

function Game:mousemoved()
end

function Game:resize()
end

function averagePoint(x1, x2, y1, y2) 
	return (x1 + x2) / 2, (y1 + y2) /2
end

return Game
