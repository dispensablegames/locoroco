local utils = require("utils")

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
		local shape = love.physics.newChainShape(true, points)
		local fixture = love.physics.newFixture(body, shape)
		fixture:setFriction(3) 
		fixture:setUserData({name = "foreground object"})
		local color = utils.parseColor(path.style.fill)
		local hbody = { color = color, body = body, shape = shape, fixture = fixture }
		if path:getStyle("rotate") then
			body:setAngularVelocity(tonumber(path:getStyle("rotate")))
		else 
			local points = utils.getWorldPoints(body, shape)
			local triangles = love.math.triangulate(points)
			hbody.triangles = triangles
		end
		table.insert(foreground.hardbodies, hbody)
	end

	self.__index = self
	setmetatable(foreground, self)

	return foreground
end

function Foreground:draw()
	for i, hbody in ipairs(self.hardbodies) do
		love.graphics.setColor(hbody.color)
		if hbody.triangles then 
			for j,triangle in ipairs(hbody.triangles) do
				love.graphics.polygon("fill", triangle)
			end
		else
			local points = utils.getWorldPoints(hbody.body, hbody.shape)
			for j,triangle in ipairs(love.math.triangulate(points)) do
				love.graphics.polygon("fill", triangle)
			end
		end
	end
end

return Foreground
