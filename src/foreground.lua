local Path = require("path")

local Foreground = {}

function Foreground:init(paths)
	local foreground = {}
	foreground.paths = paths
	foreground.hardbodies = {}

	for i,path in ipairs(foreground.paths) do 
		local points = path:getPoints()
		local avgX, avgY = utils.averagePoints(points)
		utils.shiftPoints(points, avgX, avgY)

		local body = love.physics.newBody(world, avgX, avgY, "kinematic")
		if path:getStyle("rotate") then
			body:setAngularVelocity(tonumber(path:getStyle("rotate")))
		end
		local shape = love.physics.newChainShape(true, unpack(points))
		local fixture = love.physics.newFixture(body, shape)
		fixture:setFriction(3) 
		local color = utils.parseColor(path.style.fill)
		local hbody = { color = color, body = body, shape = shape }
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
end

return Foreground
