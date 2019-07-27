Loco = {}
freeId_ = 1
		
function Loco:init(world, x, y, size, popDist)
	local baseUnit = 1000
	local scaledSize = math.floor(10 + (size / 3))
	local rectWidth = 10
	local sideLengthShortening = 5 + size / 3
	local radius = math.sqrt(size * baseUnit)
	local ropeJointMaxLength = 4 + size / 3
	local dampingRatio = 1.5
	local frequency = 1.5
	local friction = 0.05
	local finishedLoco = {}
	
	finishedLoco.numRects_ = scaledSize
	finishedLoco.size_ = size
	
	finishedLoco.bigCircle_ = {}
	finishedLoco.bigCircle_.body = love.physics.newBody(world, x, y, "dynamic")
	finishedLoco.bigCircle_.shape = love.physics.newCircleShape(radius)
	finishedLoco.bigCircle_.fixture = love.physics.newFixture(finishedLoco.bigCircle_.body, finishedLoco.bigCircle_.shape)
	finishedLoco.bigCircle_.fixture:setUserData({name="circle", parent=finishedLoco})
	finishedLoco.bigCircle_.fixture:setSensor(true)
	
	finishedLoco.bigCircle_.body:setMass(0)
	
	finishedLoco.smallRects_ = {}
	
	local rectCenters, sideLength, angleList = ngon(x, y, radius, scaledSize)
	local poppedRectCenters = ngon(x, y, radius + popDist, scaledSize)
	
	for i, angle in ipairs(angleList) do
		local smallRect = {}
		smallRect.body = love.physics.newBody(world, poppedRectCenters[2*i - 1], poppedRectCenters[2*i], "dynamic")
		smallRect.shape = love.physics.newRectangleShape(0, 0, rectWidth, sideLength - sideLengthShortening, math.pi/2 - angle)
		smallRect.fixture = love.physics.newFixture(smallRect.body, smallRect.shape)
		smallRect.fixture:setFriction(friction)
		smallRect.fixture:setUserData({name="smallRect"})
				
		smallRect.leftPoint = {}
		smallRect.rightPoint = {}
		smallRect.leftPoint.x = poppedRectCenters[2*i - 1] + math.cos(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.leftPoint.y = poppedRectCenters[2*i] + math.sin(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.rightPoint.x = poppedRectCenters[2*i - 1] - math.cos(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.rightPoint.y = poppedRectCenters[2*i] - math.sin(math.pi - angle)*(sideLength - sideLengthShortening)/2
		
		table.insert(finishedLoco.smallRects_, smallRect)
	end
	
	finishedLoco.ropeJoints_ = {}
	
	for i=1, scaledSize - 1, 1 do
		local thisRect = finishedLoco.smallRects_[i]
		local nextRect = finishedLoco.smallRects_[i + 1]
		local ropeJoint = love.physics.newRopeJoint(thisRect.body, nextRect.body, thisRect.rightPoint.x, thisRect.rightPoint.y, nextRect.leftPoint.x, nextRect.leftPoint.y, ropeJointMaxLength, false)
		table.insert(finishedLoco.ropeJoints_, ropeJoint)
	end
	
	local firstRect = finishedLoco.smallRects_[1]
	local lastRect = finishedLoco.smallRects_[scaledSize]
	local finalRopeJoint = love.physics.newRopeJoint(lastRect.body, firstRect.body, lastRect.rightPoint.x, lastRect.rightPoint.y, firstRect.leftPoint.x, firstRect.leftPoint.y, ropeJointMaxLength, false)
	table.insert(finishedLoco.ropeJoints_, finalRopeJoint)
	
	finishedLoco.distanceJoints_ = {}
	
	for i, rect in ipairs(finishedLoco.smallRects_) do
		local x, y = rect.body:getWorldCenter()
		local distanceJoint = love.physics.newDistanceJoint(rect.body, finishedLoco.bigCircle_.body, x, y, rectCenters[2*i - 1], rectCenters[2*i], false)
		distanceJoint:setDampingRatio(dampingRatio)
		distanceJoint:setFrequency(frequency)
		distanceJoint:setLength(0)
		table.insert(finishedLoco.distanceJoints_, distanceJoint)
	end
		
	self.__index = self
	setmetatable(finishedLoco, self)

	finishedLoco:setId()

	return finishedLoco
end

function Loco:getPosition()
	return self.bigCircle_.body:getPosition()
end

function Loco:getRadius()
	return self.bigCircle_.shape:getRadius()
end

function Loco:getSize()
	return self.size_
end

function Loco:getNumRects()
	return self.numRects_
end

function Loco:getMass()
	return self:getNumRects() * self.smallRects_[1].body:getMass() + self.bigCircle_.body:getMass()
end

function Loco:setId()
	self.id = freeId_
	freeId_ = freeId_ + 1
end

function Loco:getId()
	return self.id
end

function Loco:drawFace()
	local centerX, centerY = self:getPosition()
	local edgeX, edgeY = self.distanceJoints_[1]:getAnchors()

	

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.circle("fill", centerX, centerY, 5)
	love.graphics.circle("fill", edgeX, edgeY, 5)
end

function Loco:impulse(x, y)
	local powerRatio = self:getMass() / self:getNumRects()
	for i, rect in ipairs(self.smallRects_) do
		rect.body:applyLinearImpulse(x * powerRatio, y * powerRatio)
	end
	self.bigCircle_.body:applyLinearImpulse(x * powerRatio, y * powerRatio) -- remove?
end

function Loco:getJumpability()
	for i, rect in ipairs(self.smallRects_) do
		for i, contact in ipairs(rect.body:getContacts()) do
			x, y = contact:getNormal()
			if y < -0.2 then
				return true
			end
		end
	end
	return false
end

function Loco:draw(debugState)
	if debugState then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.id, self:getPosition())
		local x, y = self:getPosition()
		local r = self:getRadius()
		love.graphics.circle("line", x, y, r)
		love.graphics.setColor(255, 0, 0)
		for i, rect in ipairs(self.smallRects_) do
			love.graphics.polygon("line", rect.body:getWorldPoints(rect.shape:getPoints()))
		end
		love.graphics.setColor(0, 255, 0)
		for i, joint in ipairs(self.ropeJoints_) do
			love.graphics.line(joint:getAnchors())
		end
			love.graphics.setColor(0, 0, 255)
		for i, joint in ipairs(self.distanceJoints_) do
			love.graphics.line(joint:getAnchors())
		end

	else
		self:normalDraw()
		self:drawFace()
	end
end

function Loco:getLocoCollision()
	for i, contact in ipairs(self.bigCircle_.body:getContacts()) do
		local fixture1, fixture2 = contact:getFixtures()
		local userData1 = fixture1:getUserData()
		local userData2 = fixture2:getUserData()
		if type(userData1) == "table" and type(userData2) == "table" and userData1.name == "circle" and userData2.name == "circle" then
			if userData1.parent:getId() == self:getId() then
				return userData2.parent
			else
				return userData1.parent
			end
		end
	end
	return nil
end
 
function Loco:delete()
	for i, rect in ipairs(self.smallRects_) do
		rect.body:destroy()
	end
	for i, joint in ipairs(self.ropeJoints_) do
		if not joint:isDestroyed() then
			joint:destroy()
		end
	end
	for i, joint in ipairs(self.distanceJoints_) do
		if not joint:isDestroyed() then
			joint:destroy()
		end
	end
	self.bigCircle_.body:destroy()
end

function Loco:breakApart()
	if self:getSize() == 1 then
		return { [self:getId()]=self }
	end
	local newLocos = {}
	local x, y = self:getPosition()
	local donePoints = {}	
	for i=1, self:getSize() do
		local newX, newY = self:getSuitablePoint(donePoints, 40, 30)

		local newLoco = Loco:init(world, newX, newY, 1, -20)
		table.insert(donePoints, {x=newX, y=newY})
		newLocos[newLoco:getId()] = newLoco
	end
	self:delete()
	return newLocos
end

function Loco:getSuitablePoint(prevPoints, minDist, rad)
	local x, y = self:getPosition()
	local newX, newY = nil
	local r = self:getRadius() 

	while true do
		newX = love.math.random(x - r, x+ r)
		newY = love.math.random(y - r, y + r)
		if not self:checkPoint(newX, newY, minDist, rad, prevPoints) then
			return newX, newY
		end
	end
end

function Loco:checkPoint(x, y, minDist, rad, prevPoints)
	local collision = false
	local contacts = self.bigCircle_.body:getContacts()

	for i, contact in ipairs(contacts) do
		local fixture = self:getOtherContactFixture(contact)
		if fixture:getUserData().name == "foreground object" then
			if checkChainShapeCollision(fixture, x + rad, y) or checkChainShapeCollision(fixture, x - rad, y) or checkChainShapeCollision(fixture, x, y + rad) then
				return true
			end
		end
	end
	for i, point in ipairs(prevPoints) do
		if (math.sqrt((point.x - x) * (point.x - x) + (point.y - y) * (point.y - y)) < minDist) then
			return true
		end
	end
	return false
end

function Loco:getOtherContactFixture(contact)
	local fixture1, fixture2 = contact:getFixtures()
	local name1 = fixture1:getUserData().name
	if name1 == "bigcircle" and fixture1:getUserData().parent:getId() == self:getId() then
		return fixture2
	else
		return fixture1
	end
end

--helpers

function ngon(x, y, r, n)
	local angle = math.pi - ((n - 2) * math.pi) / n
	local angle = math.pi - ((n - 2) * math.pi) / n
	local points = {}
	local angleList = {}
	for i=0,(n-1) do
		local curAngle = i*angle
		local newX = math.cos(curAngle)*r + x
		local newY = math.sin(curAngle)*r + y
		table.insert(angleList, math.pi/2 - curAngle)
		table.insert(points, newX)
		table.insert(points, newY)
	end
	
	local sidelength = 2*r*math.sin(angle / 2)
	
	return points, sidelength, angleList
end

function checkChainShapeCollision(fixture, x, y)
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

--[[
MIT License

Copyright (c) 2018 exezin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

function tessellate(vertices, new_vertices)
  local MIX_FACTOR = .5
  new_vertices[#vertices*2] = 0
  for i=1,#vertices,2 do
    local newindex = 2*i
      new_vertices[newindex - 1] = vertices[i];
      new_vertices[newindex] = vertices[i+1]
    if not (i+1 == #vertices) then
      new_vertices[newindex + 1] = (vertices[i] + vertices[i+2])/2
      new_vertices[newindex + 2] = (vertices[i+1] + vertices[i+3])/2
    else
      new_vertices[newindex + 1] = (vertices[i] + vertices[1])/2
      new_vertices[newindex + 2] = (vertices[i+1] + vertices[2])/2
    end
  end

  for i = 1,#new_vertices,4 do
    if i == 1 then
      -- x coordinate
      new_vertices[1] = MIX_FACTOR*(new_vertices[#new_vertices - 1] + new_vertices[3])/2 + (1 - MIX_FACTOR)*new_vertices[1]
      -- y coordinate
      new_vertices[2] = MIX_FACTOR*(new_vertices[#new_vertices - 0] + new_vertices[4])/2 + (1 - MIX_FACTOR)*new_vertices[2]
    else
      -- x coordinate
      new_vertices[i] = MIX_FACTOR*(new_vertices[i - 2] + new_vertices[i + 2])/2 + (1 - MIX_FACTOR)*new_vertices[i]
      -- y coordinate
      new_vertices[i + 1] = MIX_FACTOR*(new_vertices[i - 1] + new_vertices[i + 3])/2 + (1 - MIX_FACTOR)*new_vertices[i + 1]
    end
  end
end

function Loco:normalDraw()
	love.graphics.setColor(237 / 255, 181 / 255, 40 / 255)
    local t = {{}, {}}
    for i,v in ipairs(self.smallRects_) do
		local x, y = v.body:getWorldPoints(v.shape:getPoints())
        table.insert(t[1], x)
        table.insert(t[1], y)

    end

    love.graphics.setLineWidth(10)
    tessellate(t[1], t[2]);

    local ok, tri = pcall(love.math.triangulate, t[2])
    if not ok then
		love.graphics.polygon("fill", t[2])
		love.graphics.line(t[2][#t[2]-1], t[2][#t[2]], t[2][1], t[2][2])
		return
    end
    for i,v in ipairs(tri) do
		love.graphics.polygon("fill", v)
    end

    love.graphics.line(t[2])
    love.graphics.line(t[2][#t[2]-1], t[2][#t[2]], t[2][1], t[2][2])
    love.graphics.setLineWidth(1)

end

return Loco
