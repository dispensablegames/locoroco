Loco = {}

function Loco:init(world, x, y, size, ahoge, mouthopen, mouthclosed, shapeOverride)

	local baseUnit = 1000
	local scaledSize = math.floor(12 + (size / 2))
	local rectWidth = 3
	local sideLengthShortening = 5 + size / 3
	local radius = math.sqrt(size * baseUnit)
	local ropeJointMaxLength = 4 + size / 3
	local dampingRatio = 3 - size/40
	local frequency = 3 - size/30
	local friction = 0.05
	local finishedLoco = {}
	
	local rectAnchors, sideLength, angleList = ngon(x, y, radius, scaledSize)

	local rectCenters = nil
	local shapeoverride = shapeOverride or 0
	if type(shapeoverride) == "table" then
		rectCenters = shapeoverride
		rectCenters, angleList = utils.evenlyDistributePoints(rectCenters, scaledSize)
	else
		rectCenters = ngon(x, y, radius + shapeoverride, scaledSize)	
	end	

	finishedLoco.ahoge = ahoge
	finishedLoco.mouthopen = mouthopen
	finishedLoco.mouthclosed = mouthclosed
	finishedLoco.isMouthOpen = false
	finishedLoco.idling_ = false
	finishedLoco.numRects_ = scaledSize
	finishedLoco.size_ = size
	finishedLoco.destroyed_ = false
	
	finishedLoco.creationTime_ = love.timer.getTime()
	
	finishedLoco.targetPoint_ = nil

	finishedLoco.bigCircle_ = {}
	finishedLoco.bigCircle_.body = love.physics.newBody(world, x, y, "dynamic")
	finishedLoco.bigCircle_.shape = love.physics.newCircleShape(radius)
	finishedLoco.bigCircle_.fixture = love.physics.newFixture(finishedLoco.bigCircle_.body, finishedLoco.bigCircle_.shape)
	finishedLoco.bigCircle_.fixture:setUserData({name="circle", parent=finishedLoco})
	finishedLoco.bigCircle_.fixture:setSensor(true)

	finishedLoco.bigCircle_.body:setMass(0.01)

	finishedLoco.smallRects_ = {}

	for i, angle in ipairs(angleList) do
		local smallRect = {}
		smallRect.body = love.physics.newBody(world, rectCenters[2*i - 1], rectCenters[2*i], "dynamic")
		smallRect.shape = love.physics.newRectangleShape(0, 0, rectWidth, sideLength - sideLengthShortening, math.pi/2 - angle)
		smallRect.fixture = love.physics.newFixture(smallRect.body, smallRect.shape)
		smallRect.fixture:setFriction(friction)
		smallRect.fixture:setUserData({name="smallRect"})
				
		smallRect.leftPoint = {}
		smallRect.rightPoint = {}
		smallRect.leftPoint.x = rectCenters[2*i - 1] + math.cos(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.leftPoint.y = rectCenters[2*i] + math.sin(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.rightPoint.x = rectCenters[2*i - 1] - math.cos(math.pi - angle)*(sideLength - sideLengthShortening)/2
		smallRect.rightPoint.y = rectCenters[2*i] - math.sin(math.pi - angle)*(sideLength - sideLengthShortening)/2
		
		table.insert(finishedLoco.smallRects_, smallRect)
	end

	finishedLoco.ropeJoints_ = {}
	finishedLoco.ropeJointsB_ = {}

	for j=1, math.floor(scaledSize / 2) do
	
		for i=1, scaledSize - j do
			local thisRect = finishedLoco.smallRects_[i]
			local nextRect = finishedLoco.smallRects_[i + j]
			if j > 1 then
					local ropeJoint = love.physics.newRopeJoint(thisRect.body, nextRect.body, thisRect.rightPoint.x, thisRect.rightPoint.y, nextRect.leftPoint.x, nextRect.leftPoint.y, 1000, false)
			table.insert(finishedLoco.ropeJointsB_, ropeJoint)
			else
				local ropeJoint = love.physics.newRopeJoint(thisRect.body, nextRect.body, thisRect.rightPoint.x, thisRect.rightPoint.y, nextRect.leftPoint.x, nextRect.leftPoint.y, ropeJointMaxLength, false)
			table.insert(finishedLoco.ropeJoints_, ropeJoint)
			end
		end
	
		local firstRect = finishedLoco.smallRects_[j]
		local lastRect = finishedLoco.smallRects_[scaledSize]
		if j > 1 then
			local finalRopeJoint = love.physics.newRopeJoint(lastRect.body, firstRect.body, lastRect.rightPoint.x, lastRect.rightPoint.y, firstRect.leftPoint.x, firstRect.leftPoint.y, 1000, false)
		table.insert(finishedLoco.ropeJointsB_, finalRopeJoint)
		else
			local finalRopeJoint = love.physics.newRopeJoint(lastRect.body, firstRect.body, lastRect.rightPoint.x, lastRect.rightPoint.y, firstRect.leftPoint.x, firstRect.leftPoint.y, ropeJointMaxLength, false)
		table.insert(finishedLoco.ropeJoints_, finalRopeJoint)
		end
	end

	finishedLoco.distanceJoints_ = {}

	for i, rect in ipairs(finishedLoco.smallRects_) do
		local x, y = rect.body:getWorldCenter()
		local distanceJoint = love.physics.newDistanceJoint(rect.body, finishedLoco.bigCircle_.body, x, y, rectAnchors[2*i - 1], rectAnchors[2*i], false)
		distanceJoint:setDampingRatio(dampingRatio)
		distanceJoint:setFrequency(frequency)
		distanceJoint:setLength(0)
		table.insert(finishedLoco.distanceJoints_, distanceJoint)
	end

	finishedLoco.dampingRatio_ = dampingRatio
	finishedLoco.frequency_ = frequency

	self.__index = self
	setmetatable(finishedLoco, self)

	finishedLoco:setId()

	return finishedLoco
end

function Loco:rotate(angle)
	self.bigCircle_.body:setAngle(angle)
	for i, rect in ipairs(self.smallRects_) do
		local x, y, x2, y2 = self.distanceJoints_[i]:getAnchors()
		rect.body:setPosition(x, y)
	end
end
	
function Loco:getCreationTime()	
	return self.creationTime_
end

function Loco:getDestroyed()
	return self.destroyed_
end

function Loco:setTarget(x, y, override)
	local override = override or nil
	if override then
		self.targetPoint_ = override
	else
		self.targetPoint_ = {x=x, y=y}
	end
end

function Loco:openMouth()
	self.isMouthOpen = true
end

function Loco:getRectCenters()
	local returnTable = {}
	for i, rect in ipairs(self.smallRects_) do
		local x, y = rect.body:getPosition()
		table.insert(returnTable, x)
		table.insert(returnTable, y)
	end
	return returnTable
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

function Loco:setSpringValues(dampingMult, frequencyMult)
	for i, joint in ipairs(self.distanceJoints_) do
		joint:setDampingRatio(self.dampingRatio_ * dampingMult)
		joint:setFrequency(self.frequency_ * frequencyMult)
	end
end

function Loco:setId(id)
	self.id = id
end

function Loco:getId()
	return self.id
end

function Loco:getLinearVelocity()
	return self.bigCircle_.body:getLinearVelocity()
end

function Loco:getAngularVelocity()
	return self.bigCircle_.body:getAngularVelocity()
end

function Loco:setLinearVelocity(vx, vy)
	self.bigCircle_.body:setLinearVelocity(vx, vy)
	for i, rect in ipairs(self.smallRects_) do
		rect.body:setLinearVelocity(vx, vy)
	end
end

function Loco:setAngularVelocity(w)
	self.bigCircle_.body:setAngularVelocity(w)
end

function Loco:impulse(x, y)
	local powerRatio = self:getMass() / self:getNumRects()
	for i, rect in ipairs(self.smallRects_) do
		rect.body:applyLinearImpulse(x * powerRatio, y * powerRatio)
	end
	self.bigCircle_.body:applyLinearImpulse(x * powerRatio, y * powerRatio)
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
	love.graphics.setBlendMode("alpha", "alphamultiply")
	if debugState then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.size_, self:getPosition())
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
		self:drawEyes()
		self:drawMouth()
		self:drawAhoge()
	end
end

function Loco:drawAhoge()
	local centerX, centerY = self:getPosition()
	local edgeX, edgeY = self.distanceJoints_[1]:getAnchors()
	local angle = math.pi / 2 + self.bigCircle_.body:getAngle()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")
	if self.size_ == 1 then
		local width = self.ahoge.width
		local height = self.ahoge.height
		love.graphics.draw(self.ahoge.image, edgeX + math.sin(angle) * height, edgeY - math.cos(angle) * height, angle)
	else
		local width = self.ahoge.width + 10
		local height = self.ahoge.height - 10
		love.graphics.draw(self.ahoge.image, edgeX - math.cos(angle)*height + math.cos(math.pi/2-angle)*width/2, edgeY - math.sin(angle)*height - math.sin(math.pi/2 - angle)*width/2, angle)
	end
end

function Loco:drawMouth()
	local image = nil
	local retraction = nil
	if self.isMouthOpen then
		image = self.mouthopen
		retraction = 40
	else
		image = self.mouthclosed
		retraction = 35
	end
		
	local centerX, centerY = self:getPosition()
	local edgeX, edgeY = self.distanceJoints_[1]:getAnchors()

	local angle = self.bigCircle_.body:getAngle()

	local mouthCenterX = edgeX - math.cos(angle) * retraction
	local mouthCenterY = edgeY - math.sin(angle) * retraction
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(image.image, mouthCenterX, mouthCenterY, math.pi / 2 + angle, 1, 1, image.width / 2, image.height / 2)
end

function Loco:drawEyes()
	local eyeSeparation = 13
	local eyeRetraction = 16

	local centerX, centerY = self:getPosition()
	local edgeX, edgeY = self.distanceJoints_[1]:getAnchors()

	local angle = self.bigCircle_.body:getAngle()

	local eyeCenterX = edgeX - math.cos(angle)*eyeRetraction
	local eyeCenterY = edgeY - math.sin(angle)*eyeRetraction


	local angle2 = math.pi - angle
	local eye1X, eye1Y, eye2X, eye2Y = nil

	eye1X = eyeCenterX - math.sin(angle2)*eyeSeparation
	eye1Y = eyeCenterY - math.cos(angle2)*eyeSeparation
	eye2X = eyeCenterX + math.sin(angle2)*eyeSeparation
	eye2Y = eyeCenterY + math.cos(angle2)*eyeSeparation

	love.graphics.setColor(1, 1, 1)

	love.graphics.circle("fill", eye1X, eye1Y, 7)
	love.graphics.circle("fill", eye2X, eye2Y, 7)


	love.graphics.setColor(84/255, 61/255, 19/255)
	
	if self.targetPoint_ then
		local targetX, targetY = nil
		if self.targetPoint_ == "self" then
			targetX, targetY = self:getPosition()
		else
			targetX = self.targetPoint_.x
			targetY = self.targetPoint_.y
		end

		for i, eye in ipairs({{x=eye1X, y=eye1Y}, {x=eye2X, y=eye2Y}}) do
			angle = utils.quadAwareATan(targetY - eye.y, targetX - eye.x)
			love.graphics.circle("fill", eye.x + math.cos(angle)*4, eye.y + math.sin(angle)*4, 4)
		end			
	else
		love.graphics.circle("fill", eye1X, eye1Y, 4)
		love.graphics.circle("fill", eye2X, eye2Y, 4)	
	end
end

function Loco:getLocoCollision() --if multiple, returns the closest one.
	local validList = {}
	for i, contact in ipairs(self.bigCircle_.body:getContacts()) do
		local fixture1, fixture2 = contact:getFixtures()
		local userData1 = fixture1:getUserData()
		local userData2 = fixture2:getUserData()
		if type(userData1) == "table" and type(userData2) == "table" and userData1.name == "circle" and userData2.name == "circle" then
			if userData1.parent:getId() == self:getId() then
				table.insert(validList, userData2.parent)
			else
				table.insert(validList, userData1.parent)
			end
		end
	end
	if #validList == 0 then
		return nil
	end
	local minDist = 9999
	local minLoco = nil
	for i, loco in ipairs(validList) do
		local x1, y1 = self:getPosition()
		local x2, y2 = loco:getPosition()
		local dist = math.sqrt((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1))
		if minDist > dist then
			minDist = dist
			minLoco = loco
		end
	end
	return minLoco
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
	for i, joint in ipairs(self.ropeJointsB_) do
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
	self.destroyed_ = true
end

function Loco:deleteBJoints() 
	for i, joint in ipairs(self.ropeJointsB_) do
		if not joint:isDestroyed() then
			joint:destroy()
		end
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
