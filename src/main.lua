local Level = require("level")
local Loco = require("loco")
local Camera = require("camera")

function love.load()
	love.physics.setMeter(16)
	
	gravAngle = 0
	maxAngle = 0.3
	
	jumpStr = 0

	world = love.physics.newWorld(0, 9.81*16, true)

	level = Level:init("levels/level1.svg")
	
	locos = {}
	love.graphics.setBackgroundColor(255, 255, 255)

	secondsPassed = 0
end

function love.update(dt)
	for i=1, 3 do
		world:update(dt)
	end
	if love.keyboard.isDown("c") then	
		secondsPassed = secondsPassed + 1 * dt
		if secondsPassed > 0.5 then
			secondsPassed = 0
			local newTable = {}
			for i, loco1 in pairs(locos) do
				local loco2 = loco1:getLocoCollision()
				if loco2 then
					local x1, y1 = loco1:getPosition()
					local x2, y2 = loco2:getPosition()
					local newX, newY = averagePoint(x1, x2, y1, y2)
					newX = newX + 30
					local newSize = loco1:getSize() + loco2:getSize()
					locos[loco1:getId()] = nil
					locos[loco2:getId()] = nil
					loco1:delete()
					loco2:delete()
					local newLoco = Loco:init(world, newX, newY, newSize, newSize * -1)
					newTable[newLoco:getId()] = newLoco
				end
			end
			tableAppendFunky(locos, newTable)
		end
	end
	
 	if love.keyboard.isDown("right") then
 	 	if gravAngle < maxAngle then
			gravAngle = gravAngle + 0.01
			Camera:setRotation(gravAngle)
			world:setGravity(math.sin(gravAngle)*9.81*16, math.cos(gravAngle)*9.81*16)
		end
	elseif love.keyboard.isDown("left") then
		if gravAngle > - maxAngle then
			gravAngle = gravAngle - 0.01
			Camera:setRotation(gravAngle)
			world:setGravity(math.sin(gravAngle)*9.81*16, math.cos(gravAngle)*9.81*16)
		end
	end
	if love.keyboard.isDown("space") and jumpStr < 30 then
		jumpStr = jumpStr + 2
	end
end 
	
function love.draw()
	love.graphics.print(jumpStr, 100, 100)
	love.graphics.print(gravAngle, 100, 110)
	if #locos > 0 then 	
		for i,loco in pairs(locos) do
			local locoX, locoY = loco:getPosition()
			Camera:set(locoX, locoY)
			break
		end
	else
		Camera:set(0, 0)
	end
	for i, loco in pairs(locos) do
		love.graphics.setColor(0, 255, 255)
		loco:draw(false)
		if love.keyboard.isDown("t") then
			love.graphics.setColor(255, 255, 0)
			loco:draw(true)
		end
	end
	level:draw()
	Camera:unset()
end

function love.keyreleased(key)
	if key == "1" then
		local loco = Loco:init(world, 100, -500, 1, 0)
		locos[loco:getId()] = loco
	elseif key == "2" then
		local loco = Loco:init(world, 100, -500, 2, 0)
		locos[loco:getId()] = loco
	elseif key == "3" then
		local loco = Loco:init(world, 100, -500, 3, 0)
		locos[loco:getId()] = loco
	elseif key == "4" then
		local loco = Loco:init(world, 100, -500, 4, 0)
		locos[loco:getId()] = loco
	elseif key == "5" then
		local loco = Loco:init(world, 200, -400, 5, 0)
		locos[loco:getId()] = loco
	elseif key == "6" then
		local loco = Loco:init(world, 100, -500, 6, 0)
		locos[loco:getId()] = loco
	elseif key == "7" then
		local loco = Loco:init(world, 100, -500, 7, 0)
		locos[loco:getId()] = loco
	elseif key == "8" then
		local loco = Loco:init(world, 100, -500, 8, 0)
		locos[loco:getId()] = loco
	elseif key == "9" then
		local loco = Loco:init(world, 100, -500, 9, 0)
		locos[loco:getId()] = loco
	elseif key == "0" then
		local loco = Loco:init(world, 200, -400, 20, 0)
		locos[loco:getId()] = loco
	elseif key == "d" then
		for i, loco in pairs(locos) do
			locos[loco:getId()] = nil
			loco:delete()
			break
		end

	elseif key == "c" then
		secondsPassed = 0


	elseif key == "p" then
		local newTable = {}
		for i, loco in pairs(locos) do
			tableAppendFunky(newTable, loco:breakApart())
			locos[loco:getId()] = nil
		end
		locos = newTable


	elseif key == "space" then
		for i, loco in pairs(locos) do
			if loco:getJumpability() then
				loco:impulse(0, -jumpStr*10)
			end
		end
		jumpStr = 0
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
