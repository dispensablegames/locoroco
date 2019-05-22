love.blobs = require "loveblobs"
local util = require "loveblobs.util"

local softbodies = {}
local hardbodies = {}
local mousejoint = nil

-- TODO: try changing mass of objects

function softloco(a, b, r, precision)
	--local slopes = { 0, math.tan(math.pi / 8), 1, math.tan(3 * math.pi / 8) }
	local slopes = { 0, 1 / math.sqrt(3), math.sqrt(3) }
	local points = {}
	len = 1
	for i=1,#slopes do
		slope = slopes[i]
		points[len] = math.sqrt(r^2 / (1 + slope ^ 2)) 
		points[len + 1] = slope * points[len]
		len = len + 2
	end
	for i=1,#slopes*2,2 do
		points[len] = - points[i + 1]
		points[len + 1] = points[i]
		len = len + 2
	end
	for i=1,#slopes*2,2 do
		points[len] = - points[i]
		points[len + 1] = - points[i + 1]
		len = len + 2
	end
	for i=1,#slopes*2,2 do
		points[len] = points[i + 1]
		points[len + 1] = - points[i]
		len = len + 2
	end

	for i,v in ipairs(points) do
		if i % 2 == 0 then
			points[i] = v + b
		else
			points[i] = v + a
		end
	end
  local bl = {}
  bl = love.blobs.softsurface(world, points, precision, "dynamic")
  bl.cols = 0
  bl.center = {}
  --bl.center.body = love.physics.newBody(world, a, b, "dynamic")
  --bl.center.joint = love.physics.newWeldJoint(bl.center.body, bl.phys[1].body, a, b, false)
  return bl

end

function love.load()
	-- init the physics world
	love.physics.setMeter(16)
	world = love.physics.newWorld(0, 9.81*16, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	gravAngle = 0
	maxAngle = 0.3
	cameraX = 0
	cameraY = 0
	holdTime = 0
	maxHoldTime = 3.5

	polygons = import()

	for i,polygon in ipairs(polygons) do 
		local polygonTable = {}
		polygonTable.body = love.physics.newBody(world, 0, 0, "static")
		polygonTable.shape = love.physics.newPolygonShape(polygon)
		polygonTable.fixture = love.physics.newFixture(polygonTable.body, polygonTable.shape)
		polygonTable.fixture:setUserData(nil)
		table.insert(hardbodies,polygonTable)
	end

	-- init the loco
	table.insert(softbodies, softloco(200,100,100,13))

	love.graphics.setBackgroundColor(255, 255, 255)
end

function beginContact(a, b, coll)
	if a:getUserData() and not b:getUserData() then
	   a:getUserData().cols = a:getUserData().cols + 1
	   --print(a:getUserData().cols)
	elseif b:getUserData() and not a:getUserData() then
	   b:getUserData().cols = b:getUserData().cols + 1
	   --print(b:getUserData().cols)
	end
end
 
function endContact(a, b, coll)
	if a:getUserData() and not b:getUserData() then
	   a:getUserData().cols = a:getUserData().cols - 1
	   --print(a:getUserData().cols)
	elseif b:getUserData() and not a:getUserData() then
	   b:getUserData().cols = b:getUserData().cols - 1
	   --print(b:getUserData().cols)
	end
end

function love.update(dt)
  -- update the physics world
  for i=1,4 do
    world:update(dt)
  end
  
 	if love.keyboard.isDown("right") and love.keyboard.isDown("left")  then
		if holdTime < maxHoldTime then
			holdTime = holdTime + 40 * dt
		end
	elseif love.keyboard.isDown("left") then
		if gravAngle > - maxAngle then
			gravAngle = gravAngle - 0.01
			world:setGravity(math.sin(gravAngle)*9.81*16, math.cos(gravAngle)*9.81*16)
		end
	elseif love.keyboard.isDown("right") then
 	 	if gravAngle < maxAngle then
			gravAngle = gravAngle + 0.01
			world:setGravity(math.sin(gravAngle)*9.81*16, math.cos(gravAngle)*9.81*16)
		end
	end
end

function love.keyreleased(key)
	if key == "right" or key == "left" then
		if softbodies[1].cols > 0 then
			print(holdTime)
			for i,v in ipairs(softbodies) do
				v:impulse(0,-9.81 * holdTime)
			end
			holdTime = 0
		end
	end
end

function import()
	local file = io.open("src/level.loco", "r")
	io.input(file)
	if not file then
		print("there isnt a file")
	end
	local str = io.read("*all")
	local polygons = {}
	for polygon in string.gmatch(str, "[^\n]+\n") do
		print("polygon:")
		print(polygon)
		local polygonTable = {}
		for point in string.gmatch(polygon, "[^ \n]+") do
			print("point:")
			print(point)
			table.insert(polygonTable, point)
		end
		table.insert(polygons, polygonTable)
	end

	file:close()

	return polygons

end
		

function love.draw()
	

	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local x1, y1, x2, y2, x3, y3, x4, y4 = softbodies[1].phys[1].body:getWorldPoints(softbodies[1].phys[1].shape:getPoints())
	local x5 = (x1 + x2) / 2
	local y5 = (y1 + y2) / 2
	local x6 = (x3 + x4) / 2
	local y6 = (y3 + y4) / 2
	local angle = math.atan2(y6 - y5, x6 - x5)
	love.graphics.translate(width/2, height/2)
	love.graphics.rotate(gravAngle)
	love.graphics.translate(-width/2, -height/2)
	local locoX = -x5 - math.cos(angle)*105
	local locoY = -y5 - math.sin(angle)*105
	local distX = locoX - cameraX
	local distY = locoY - cameraY
	cameraX = cameraX + distX/15
	cameraY = cameraY + distY/15
	love.graphics.translate(cameraX + width/2, cameraY + height/2)

  love.graphics.setColor(0,0,0)
  for i,polygon in ipairs(polygons) do
  	love.graphics.polygon("fill", polygon)
	end
  for i,v in ipairs(softbodies) do
    if love.getVersion == 0 then
      love.graphics.setColor(50*i, 100, 200*i)
    else
      love.graphics.setColor(0.2*i, 0.4, 0.8*i)
    end
     v:draw(false)
  end

	love.graphics.setColor(255,0,255)
	local curve = love.math.newBezierCurve(12.492589,166.83974,  40.00977,-54.87048, 92.032091,-65.69506, 145.887211,3.20723)
	love.graphics.polygon("fill",curve:render())






end
