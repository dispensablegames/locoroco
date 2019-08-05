local Camera = require("camera")
local Level = require("level")
local Loco = require("loco")
local Game = {}

function Game:init(filename)
	local game = {}
	local world = love.physics.newWorld(0, 9.81*16, true)
	game.world = world
	game.level = Level:init(world, filename)
	game.gravAngle = 0
	game.maxAngle = 0.3
	game.jumpStr = 0
	game.locos = {}
	love.graphics.setBackgroundColor(255, 255, 255)
	game.secondsPassed = 0

	self.__index = self
	setmetatable(game, self)

	return game
end

function Game:update(dt)
	for i=1, 3 do
		self.world:update(dt)
	end

	print(self.world:getBodyCount())

	self.level:update(dt, Camera)

	if love.keyboard.isDown("c") then	
		self.secondsPassed = self.secondsPassed + 1 * dt
		if self.secondsPassed > 0.5 then
			self.secondsPassed = 0
			local newTable = {}
			for i, loco1 in pairs(self.locos) do
				local loco2 = loco1:getLocoCollision()
				if loco2 then
					local x1, y1 = loco1:getPosition()
					local x2, y2 = loco2:getPosition()
					local newX, newY = averagePoint(x1, x2, y1, y2)
					newX = newX + 30
					local newSize = loco1:getSize() + loco2:getSize()
					self.locos[loco1:getId()] = nil
					self.locos[loco2:getId()] = nil
					loco1:delete()
					loco2:delete()
					local newLoco = Loco:init(world, newX, newY, newSize, newSize * -1)
					newTable[newLoco:getId()] = newLoco
				end
			end
			tableAppendFunky(self.locos, newTable)
		end
	end
	
 	if love.keyboard.isDown("right") then
 	 	if self.gravAngle < self.maxAngle then
			self.gravAngle = self.gravAngle + 0.01
			Camera:setRotation(self.gravAngle)
			self.world:setGravity(math.sin(self.gravAngle)*9.81*16, math.cos(self.gravAngle)*9.81*16)
		end
	elseif love.keyboard.isDown("left") then
		if self.gravAngle > - self.maxAngle then
			self.gravAngle = self.gravAngle - 0.01
			Camera:setRotation(self.gravAngle)
			self.world:setGravity(math.sin(self.gravAngle)*9.81*16, math.cos(self.gravAngle)*9.81*16)
		end
	end
	if love.keyboard.isDown("space") and self.jumpStr < 30 then
		self.jumpStr = self.jumpStr + 2
	end
end

function Game:draw()
	love.graphics.scale(0.75)
	love.graphics.print(self.jumpStr, 100, 100)
	love.graphics.print(self.level.spawnX, 100, 110)
	love.graphics.print(self.level.spawnY, 100, 120)

	if #self.locos > 0 then 	
		for i,loco in pairs(self.locos) do
			local locoX, locoY = loco:getPosition()
			Camera:set(locoX, locoY)
			break
		end
	else
		Camera:set(self.level.spawnX, self.level.spawnY)
	end
	self.level:draw()
	for i, loco in pairs(self.locos) do
		love.graphics.setColor(0, 255, 255)
		loco:draw(false)
		if love.keyboard.isDown("t") then
			love.graphics.setColor(255, 255, 0)
			loco:draw(true)
		end
	end

	Camera:unset()
end

function Game:keyreleased(key)
	local locos = self.locos
	local world = self.world
	local level = self.level
	if key == "1" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 1, 0)
		locos[loco:getId()] = loco
	elseif key == "2" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 2, 0)
		locos[loco:getId()] = loco
	elseif key == "3" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 3, 0)
		locos[loco:getId()] = loco
	elseif key == "4" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 4, 0)
		locos[loco:getId()] = loco
	elseif key == "5" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 5, 0)
		locos[loco:getId()] = loco
	elseif key == "6" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 6, 0)
		locos[loco:getId()] = loco
	elseif key == "7" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 7, 0)
		locos[loco:getId()] = loco
	elseif key == "8" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 8, 0)
		locos[loco:getId()] = loco
	elseif key == "9" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 9, 0)
		locos[loco:getId()] = loco
	elseif key == "0" then
		local loco = Loco:init(world, level.spawnX, level.spawnY, 20, 0)
		locos[loco:getId()] = loco
	elseif key == "d" then
		for i, loco in pairs(locos) do
			locos[loco:getId()] = nil
			loco:delete()
			break
		end

	elseif key == "c" then
		self.secondsPassed = 0

	elseif key == "p" then
		local newTable = {}
		for i, loco in pairs(locos) do
			tableAppendFunky(newTable, loco:breakApart())
			locos[loco:getId()] = nil
		end
		self.locos = newTable

	elseif key == "space" then
		for i, loco in pairs(locos) do
			if loco:getJumpability() then
				loco:impulse(0, -self.jumpStr*10)
			end
		end
		self.jumpStr = 0
	end
end

function tableAppendFunky(table1, table2)
	if table1 == nil then
		return table1
	elseif table2 == nil then
		return table2
	end
	for key,value in pairs(table2) do
		table1[key] = value
	end
end

function averagePoint(x1, x2, y1, y2) 
	return (x1 + x2) / 2, (y1 + y2) /2
end

return Game
