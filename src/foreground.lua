local Path = require("path")

local Foreground = {}

function Foreground:init(paths)
	local foreground = {}
	foreground.paths = paths
	foreground.hardbodies = {}

	for i,path in ipairs(foreground.paths) do 
		local points = path:getPoints()
		local avgX, avgY = path:getCenter()
		utils.shiftPoints(points, avgX, avgY)

		local body = love.physics.newBody(world, avgX, avgY, "kinematic")
		if path:getStyle("rotate") then
			body:setAngularVelocity(tonumber(path:getStyle("rotate")))
		end
		local shape = love.physics.newChainShape(true, unpack(points))
		local fixture = love.physics.newFixture(body, shape)
		fixture:setFriction(3) 
		local color = utils.parseColor(path.style.fill)
		local hbody = { color = color, body = body, shape = shape, fixture = fixture }
		table.insert(foreground.hardbodies, hbody)
	end

	self.__index = self
	setmetatable(foreground, self)

	return foreground
end

function Foreground:draw()
	for i, hbody in ipairs(self.hardbodies) do
		local points = { hbody.body:getWorldPoints(hbody.shape:getPoints()) }
		table.remove(points, #points)
		table.remove(points, #points)
		love.graphics.setColor(hbody.color)
		for j,triangle in ipairs(love.math.triangulate(hbody.body:getWorldPoints(hbody.shape:getPoints()))) do
			love.graphics.polygon("fill", triangle)
		end
	end
	for i,path in ipairs(self.paths) do
		love.graphics.setColor(1,0,0)
		local x, y = path:getCenter()
		love.graphics.circle("fill", x, y, 10)
		local boxpoints = { path:getBoundingBox() }
		love.graphics.polygon("line", boxpoints)
	end
end

function Foreground:isInHardbody(x, y)
	for i, hardbody in ipairs(self.hardbodies) do	
		if hardbody.fixture:testPoint(x, y) then
			return true
		end
	end
	return false
end

return Foreground
