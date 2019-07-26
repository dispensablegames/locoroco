local Level = require("level")
local Loco = require("loco")
local Camera = require("camera")

function love.load()
	love.physics.setMeter(16)
	
	gravAngle = 0
	maxAngle = 0.3
	
	jumpStr = 0

	world = love.physics.newWorld(0, 9.81*16, true)

	level = Level:init("levels/world1level1.svg")
	
	locos = {}
	love.graphics.setBackgroundColor(255, 255, 255)

	secondsPassed = 0
end

function love.update(dt)
	for i=1, 3 do
		world:update(dt)
	end

	level:update(dt, Camera)

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
	love.graphics.print(level.spawnX, 100, 110)
	love.graphics.print(level.spawnY, 100, 120)

	if #locos > 0 then 	
		for i,loco in pairs(locos) do
			local locoX, locoY = loco:getPosition()
			Camera:set(locoX, locoY)
			break
		end
	else
		Camera:set(level.spawnX, level.spawnY)
	end
	level:draw()
	for i, loco in pairs(locos) do
		love.graphics.setColor(0, 255, 255)
		loco:draw(false)
		if love.keyboard.isDown("t") then
			love.graphics.setColor(255, 255, 0)
			loco:draw(true)
		end
	end

	Camera:unset()
end

function love.keyreleased(key)
	if key == "1" then
		print(level.spawnX)
		print(level.spawnY)
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

function checkCollision(fixture, x, y)
	local shape = fixture:getShape()
	local body = fixture:getBody()
	local collisions = 0
	for i=1, shape:getChildCount() do
		local edge = shape:getChildEdge(i)
		local x1, y1, x2, y2 = body:getWorldPoints(edge:getPoints())
		if checkLineCollision(x1, y1, x2, y2, -1000, -1000, x, y) then
			collisions = collisions + 1
		end
	end
	print(collisions)
	if collisions % 2 == 0 then
		return false
	else
		return true
	end
end

function orientation(ax, ay, bx, by, cx, cy)
	local val = (by - ay) * (cx - bx) - (bx - ax) * (cy - by)
	if val == 0 then
		return "colinear"
	elseif val > 0 then
		return "clockwise"
	else
		return "counterclockwise"
	end
end

function onLine(ax, ay, bx, by, cx, cy)
	return (bx <= math.max(ax, cx) and bx >= math.min(ax, cx) and by <= math.max(ay, cy) and bx >= math.min(ay, cy))
end

function checkLineCollision(p1x, p1y, q1x, q1y, p2x, p2y, q2x, q2y)
	local orient1 = orientation(p1x, p1y, q1x, q1y, p2x, p2y)
	local orient2 = orientation(p1x, p1y, q1x, q1y, q2x, q2y)
	local orient3 = orientation(p2x, p2y, q2x, q2y, p1x, p1y)
	local orient4 = orientation(p2x, p2y, q2x, q2y, q1x, q1y)

	if (orient1 ~= orient2) and (orient3 ~= orient4) then
		return true
	elseif (orient1 == "colinear") and onLine(p1x, p1y, p2x, p2y, q1x, q1y) then
		return true
	elseif (orient2 == "colinear") and onLine(p1x, p1y, q2x, q2y, q1x, q1y) then
		return true
	elseif (orient3 == "colinear") and onLine(p2x, p2y, p1x, p1y, q2x, q2y) then
		return true
	elseif (orient4 == "colinear") and onLine(p2x, p2y, q1x, q1y, q2x, q2y) then
		return true
	else
		return false
	end
end