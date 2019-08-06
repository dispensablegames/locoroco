local utils = require("utils")

local Foreground = {}

function Foreground:init(world, paths, width, height)
	local foreground = {}

	foreground.world = world

	foreground.paths = paths
	foreground.hardbodies = {}
	foreground.hardbodiesMoving = {}
	foreground.hardbodiesStatic = {}

	foreground.triangleGrid = {}
	foreground.gridCellSize = love.graphics.getSystemLimits().texturesize
	if foreground.gridCellSize > 4096 then
		foreground.gridCellSize = 4096
	end

	self.__index = self
	setmetatable(foreground, self)


	local maxI = math.floor(width / foreground.gridCellSize)
	local maxJ = math.floor(height / foreground.gridCellSize)


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
			local canvas = love.graphics.newCanvas(foreground.gridCellSize, foreground.gridCellSize)
			love.graphics.setCanvas(canvas)
			local triangles = foreground.triangleGrid[i][j]
			print("adding triangles to canvas")
			for k,t in ipairs(triangles) do
				love.graphics.setColor(t.color)
				local triangle = t.triangle
				local newTriangle = utils.shiftPoints(triangle, i * foreground.gridCellSize, j * foreground.gridCellSize)
				love.graphics.polygon("fill", newTriangle)
			end
			love.graphics.setCanvas()
			print("creating image from canvas")
			local imageData = canvas:newImageData()
			local image = love.graphics.newImage(imageData)
			table.insert(foreground.images, { x = i * foreground.gridCellSize, y = j * foreground.gridCellSize, image = image })
			print("one canvas done")
		end
	end


	return foreground
end

function Foreground:addTriangle(triangle, color)
	local tMeta = { triangle = triangle, color = color }
	local avgX, avgY = utils.averagePoints(triangle)
	local gridCellSize = self.gridCellSize
	local grid = self.triangleGrid
	local x = math.floor(avgX / gridCellSize)
	local y = math.floor(avgY / gridCellSize)
	local cell = grid[x][y]
	table.insert(cell, tMeta)
	for i=1,#triangle - 1,2 do 
		local x = triangle[i]
		local y = triangle[i + 1]
		local gridI = math.floor(x / gridCellSize)
		local gridJ = math.floor(y / gridCellSize)
		local cell = grid[gridI][gridJ]
		if cell and cell[#cell] == tMeta then

		else
			table.insert(cell, tMeta)
		end
	end
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
	local pathPoints = path:getPoints()
	local avgX, avgY = path:getCenter()
	pathPoints = utils.shiftPoints(pathPoints, avgX, avgY)
	local body = love.physics.newBody(self.world, avgX, avgY, "dynamic")
	body:setMass(1)
	local shape = love.physics.newChainShape(true, pathPoints)	
	local fixture = love.physics.newFixture(body, shape)
	fixture:setFriction(3) 
	fixture:setUserData({ name = "foreground object" })
	local centerBody = love.physics.newBody(self.world, avgX, avgY, "kinematic")
	centerBody:setMass(1)
	local joint = love.physics.newRevoluteJoint(body, centerBody, avgX, avgY, avgX, avgY, false, math.pi / 2)
	joint:setMotorEnabled(true)
	joint:setMotorSpeed(math.pi)

	local hardbody = {}
	hardbody.color = utils.parseColor(path:getStyle("fill"))
	hardbody.body = body
	hardbody.shape = shape
	hardbody.fixture = fixture
	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesMoving, hardbody)
end

function Foreground:addAutoRotatingBody(path, speed)
	local pathPoints = path:getPoints()
	local avgX, avgY = path:getCenter()
	pathPoints = utils.shiftPoints(pathPoints, avgX, avgY)
	local body = love.physics.newBody(self.world, avgX, avgY, "kinematic")
	local shape = love.physics.newChainShape(true, pathPoints)	
	local fixture = love.physics.newFixture(body, shape)
	body:setAngularVelocity(speed)
	fixture:setFriction(3) 
	fixture:setUserData({ name = "foreground object" })

	local hardbody = {}
	hardbody.color = utils.parseColor(path:getStyle("fill"))
	hardbody.body = body
	hardbody.shape = shape
	hardbody.fixture = fixture
	table.insert(self.hardbodies, hardbody)
	table.insert(self.hardbodiesMoving, hardbody)
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
		love.graphics.setColor(hbody.color)
		local points = utils.getWorldPoints(hbody.body, hbody.shape)
		for j,triangle in ipairs(love.math.triangulate(points)) do
			love.graphics.polygon("fill", triangle)
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
