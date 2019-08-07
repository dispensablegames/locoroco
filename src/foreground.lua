local utils = require("utils")

local Foreground = {}

function Foreground:init(world, paths, width, height)
	local foreground = {}

	foreground.world = world

	foreground.paths = paths
	foreground.hardbodies = {}
	foreground.hardbodiesMoving = {}
	foreground.hardbodiesStatic = {}
	foreground.hardbodiesSecret = {}

	foreground.triangleGrid = {}
	foreground.gridCellSize = math.floor(math.sqrt(width * height / 16))
	if love.graphics.getSystemLimits().texturesize < foreground.gridCellSize then
		foreground.gridCellSize = love.graphics.getSystemLimits().texturesize
	end

	self.__index = self
	setmetatable(foreground, self)

	local maxI = math.floor(width / foreground.gridCellSize)
	local maxJ = math.floor(height / foreground.gridCellSize)

	self.triangleGridWidth = maxI
	self.triangleGridHeight = maxJ

	for i=0,maxI do
		local row = {}
		for j=0,maxJ do 
			row[j] = {}
		end
		foreground.triangleGrid[i] = row
	end
	
	print("adding bodies...")
	
	for i,path in ipairs(foreground.paths) do 
		foreground:addBody(path)
	end

	foreground.images = {}

	print("making canvases...")
	
	for i=0,maxI do
		for j=0,maxJ do
			local triangles = foreground.triangleGrid[i][j]
			local imageData = utils.imageDataFromPolygons(triangles, foreground.gridCellSize, foreground.gridCellSize, i * foreground.gridCellSize, j * foreground.gridCellSize)
			local image = love.graphics.newImage(imageData)
			table.insert(foreground.images, { x = i * foreground.gridCellSize, y = j * foreground.gridCellSize, image = image })
		end
	end


	return foreground
end

function Foreground:addTriangle(triangle, color)
	local tMeta = { points = triangle, color = color }
	local minX, minY, maxX, maxY = minMaxValues(triangle)
	local gridMinX = math.floor(minX / self.gridCellSize)
	local gridMinY = math.floor(minY / self.gridCellSize)
	local gridMaxX = math.floor(maxX / self.gridCellSize)
	local gridMaxY = math.floor(maxY / self.gridCellSize)
	for x=gridMinX, gridMaxX  do
		for y=gridMinY, gridMaxY  do
			table.insert(self.triangleGrid[x][y], tMeta)
		end
	end
end

function minMaxValues(points)
	local minX = points[1]
	local minY = points[2]
	local maxX = points[1]
	local maxY = points[2]
	for i=1,#points-1,2 do
		if points[i] > maxX then
			maxX = points[i]
		end
		if points[i] < minX then
			minX = points[i]
		end
		if points[i + 1] > maxY then
			maxY = points[i + 1]
		end
		if points[i + 1] < minY then
			minY = points[i + 1]
		end
	end
	return minX, minY, maxX, maxY
end

function Foreground:addBody(path)
	if path:getStyle("rotate") then
		if path:getStyle("rotate") == "true" then
			self:addRotatingBody(path)
		else
			self:addAutoRotatingBody(path, path:getStyle("rotate"))
		end
	elseif path:getStyle("invisible") then
		self:addInvisibleBody(path)
	elseif path:getStyle("secret") then
		self:addSecretBody(path)
	else
		self:addStaticBody(path)
	end
end

function Foreground:addInvisibleBody(path)
	local pathPoints = path:getPoints()
	local body = love.physics.newBody(self.world, 0, 0, "static")
	local shape = love.physics.newChainShape(true, pathPoints)
	local fixture = love.physics.newFixture(body, shape)
	fixture:setFriction(3)
	fixture:setUserData({ name = "foreground object" })
	local hardbody = {}
	hardbody.shape = shape
	hardbody.body = body
	hardbody.fixture = fixture

	table.insert(self.hardbodies, hardbody)
end

function Foreground:addSecretBody(path)
	local shapePoints = path:getPoints()
	local body = love.physics.newBody(self.world, 0, 0, "static")
	for i,triangle in ipairs(love.math.triangulate(shapePoints)) do
		local shape = nil
		pcall(function() shape = love.physics.newPolygonShape(triangle) end)
		if shape then
			local fixture = love.physics.newFixture(body, shape)
			fixture:setUserData({ name = "secretpiece" })
			fixture:setSensor(true)
		end
	end

	local imageData = path:toImageData()
	local image = love.graphics.newImage(imageData)
	local x, y = path:getTopLeftCorner()

	local hardbody = {}
	hardbody.body = body
	hardbody.picture = { image = image, x = x, y = y }
	hardbody.transparency = 1
	hardbody.hidden = true
	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesSecret, hardbody)
end

function Foreground:addStaticBody(path)
	local pathPoints = path:getPoints()

	local body = love.physics.newBody(self.world, 0, 0, "static")
	local tempShape = love.physics.newChainShape(true, pathPoints)
	local shapePoints = utils.getWorldPoints(body, tempShape)
	local triangles = love.math.triangulate(shapePoints)
	local color = utils.parseColor(path:getStyle("fill"))
	for i,triangle in ipairs(triangles) do
		self:addTriangle(triangle, color)
	end

	local shapes = {}
	for i,pointsChunk in ipairs(splitTable(shapePoints, 200)) do
		local shape = love.physics.newChainShape(false, pointsChunk)
		table.insert(shapes, shape)
		local fixture = love.physics.newFixture(body, shape)
		fixture:setFriction(2)
		fixture:setUserData({ name = "foreground object" })
	end

	local hardbody = {}
	hardbody.shapes = shapes
	hardbody.body = body
	hardbody.fixture = fixture

	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesStatic, hardbody)
end

function Foreground:addRotatingBody(path)
	local avgX, avgY = path:getCenter()
	local shapePoints = utils.shiftPoints(path:getPoints(), avgX, avgY)
	local body = love.physics.newBody(self.world, avgX, avgY, "dynamic")
	body:setMass(1)
	local shape = love.physics.newChainShape(true, shapePoints)	
	local fixture = love.physics.newFixture(body, shape)
	fixture:setFriction(3) 
	fixture:setUserData({ name = "foreground object" })
	local centerBody = love.physics.newBody(self.world, avgX, avgY, "kinematic")
	centerBody:setMass(1)
	local joint = love.physics.newRevoluteJoint(body, centerBody, avgX, avgY, avgX, avgY, false, math.pi / 2)
	joint:setMotorEnabled(true)
	joint:setMotorSpeed(math.pi)

	local imageData = path:toImageData()
	local image = love.graphics.newImage(imageData)
	local x, y = path:getTopLeftCorner()
	local offsetX = avgX - x
	local offsetY = avgY - y

	local hardbody = {}
	hardbody.body = body
	hardbody.fixture = fixture
	hardbody.picture = { image = image, x = avgX, y = avgY, offsetX = offsetX, offsetY = offsetY }
	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesMoving, hardbody)
end

function Foreground:addAutoRotatingBody(path, speed)
	local avgX, avgY = path:getCenter()
	local shapePoints = utils.shiftPoints(path:getPoints(), avgX, avgY)
	local body = love.physics.newBody(self.world, avgX, avgY, "kinematic")
	local shape = love.physics.newChainShape(true, shapePoints)
	local fixture = love.physics.newFixture(body, shape)
	body:setAngularVelocity(speed)
	fixture:setFriction(3) 
	fixture:setUserData({ name = "foreground object" })

	local imageData = path:toImageData()
	local image = love.graphics.newImage(imageData)
	local x, y = path:getTopLeftCorner()
	local offsetX = avgX - x
	local offsetY = avgY - y

	local hardbody = {}
	hardbody.body = body
	hardbody.fixture = fixture
	hardbody.picture = { image = image, x = avgX, y = avgY, offsetX = offsetX, offsetY = offsetY }
	hardbody.shape = shape
	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesMoving, hardbody)
end

function Foreground:drawSecretWalls()
	--very ugly

	for i,hbody in ipairs(self.hardbodiesSecret) do
		hbody.hidden = true
		for i, contact in ipairs(hbody.body:getContacts()) do
			local fixture1, fixture2 = contact:getFixtures()
			local userdata1 = fixture1:getUserData()
			local userdata2 = fixture2:getUserData()
			if userdata1.name == "circle" or userdata2.name == "circle" then
				hbody.hidden = false
				break
			end
		end
		if hbody.hidden then
			if hbody.transparency < 1 then
				if hbody.transparency < 0.5 then
					hbody.transparency = hbody.transparency + 0.1
				end
				hbody.transparency = hbody.transparency * 1.1
			end
		else
			if hbody.transparency > 0 then
				hbody.transparency = hbody.transparency * 0.9
			end
		end
		if hbody.transparency >= 1 then
			love.graphics.setBlendMode("alpha", "premultiplied")
		else 
			love.graphics.setBlendMode("alpha", "alphamultiply")
		end
		love.graphics.setColor(1, 1, 1, hbody.transparency)
		love.graphics.draw(hbody.picture.image, hbody.picture.x, hbody.picture.y)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Foreground:draw()
	for i,img in ipairs(self.images) do
		love.graphics.setColor(1,1,1)
		love.graphics.draw(img.image, img.x, img.y)
	end
--[[
	for i,hbody in ipairs(self.hardbodiesStatic) do
		for i,shape in ipairs(hbody.shapes) do
			local points = utils.getWorldPoints(hbody.body, shape)
			love.graphics.setColor(1, 0, 0)
			love.graphics.circle("fill", points[#points - 1], points[#points], 10)
		end
	end
]]--

	for i, hbody in ipairs(self.hardbodiesMoving) do
		local picture = hbody.picture
		love.graphics.draw(picture.image, picture.x, picture.y, hbody.body:getAngle(), 1, 1, picture.offsetX, picture.offsetY)
	end
	love.graphics.setColor(1, 1, 0)
	for i=0,self.triangleGridWidth do
		for j=0,self.triangleGridHeight do
				love.graphics.rectangle("line", i * self.gridCellSize, j * self.gridCellSize, self.gridCellSize, self.gridCellSize)
		end
	end
end

function splitTable(t, n)
	local tables = {}
	local tableChunk = {}
	for i=1,#t do
		table.insert(tableChunk, t[i])
		if i == #t or i % n == 0 then
			table.insert(tables, tableChunk)
			tableChunk = {}
			table.insert(tableChunk, t[i - 3])
			table.insert(tableChunk, t[i - 2])
			table.insert(tableChunk, t[i - 1])
			table.insert(tableChunk, t[i])
		end
	end
	if #tables[#tables] == 2 then
		table.insert(tables[#tables - 1], tables[#tables][1])
		table.insert(tables[#tables - 1], tables[#tables][2])
		tables[#tables] = nil
	end
	return tables
end

return Foreground
