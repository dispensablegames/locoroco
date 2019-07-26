local utils = require("utils")

local Foreground = {}

function Foreground:init(paths)
	local foreground = {}
	foreground.paths = paths
	foreground.hardbodies = {}

	for i,path in ipairs(foreground.paths) do 
		local pathPoints = path:getPoints()

		local hardbody = {}
		local color = utils.parseColor(path.style.fill)
		hardbody.color = color

		if path:getStyle("rotate") then
			local avgX, avgY = path:getCenter()
			utils.shiftPoints(pathPoints, avgX, avgY)
			local body = love.physics.newBody(world, avgX, avgY, "kinematic")
			local shape = love.physics.newChainShape(true, pathPoints)
			local fixture = love.physics.newFixture(body, shape)
			body:setAngularVelocity(path:getStyle("rotate"))
			fixture:setFriction(3) 
			fixture:setUserData({name = "foreground object"})
			hardbody.body = body
			hardbody.shape = shape
			hardbody.fixture = fixture
		else 
			local body = love.physics.newBody(world, 0, 0, "kinematic")
			local tempShape = love.physics.newChainShape(true, pathPoints)
			local shapePoints = utils.getWorldPoints(body, tempShape)
			local triangles = love.math.triangulate(shapePoints)
			hardbody.triangles = triangles
			local shapes = {}
			for i,pointsChunk in ipairs(splitTable(shapePoints, 200)) do
				print("hello")
				local shape = love.physics.newChainShape(false, pointsChunk)
				table.insert(shapes, shape)
				local fixture = love.physics.newFixture(body, shape)
				fixture:setFriction(2)
				fixture:setUserData({name = "foreground object"})
			end
			hardbody.shapes = shapes
			hardbody.body = body

		end
		table.insert(foreground.hardbodies, hardbody)
	end

	self.__index = self
	setmetatable(foreground, self)

	return foreground
end

function Foreground:draw()
	for i, hbody in ipairs(self.hardbodies) do
		love.graphics.setColor(hbody.color)
		if hbody.shapes then
			for i,triangle in ipairs(hbody.triangles) do
				love.graphics.polygon("fill", triangle)
			end
			for i,shape in ipairs(hbody.shapes) do
				local points = utils.getWorldPoints(hbody.body, shape)
				love.graphics.setColor(1, 0, 0)
				love.graphics.circle("fill", points[#points - 1], points[#points], 10)
			end
		else
			local points = utils.getWorldPoints(hbody.body, hbody.shape)
			for j,triangle in ipairs(love.math.triangulate(points)) do
				love.graphics.polygon("fill", triangle)
			end
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
