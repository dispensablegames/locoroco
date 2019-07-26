local utils = require("utils")

local UseBatch = {}

function UseBatch:init(path)
	local usebatch = {}
	usebatch.path = path
	usebatch.uses = {}

	local canvas = love.graphics.newCanvas(path:getWidth(), path:getHeight())
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(utils.parseColor(path:getStyle("fill")))
	local points = path:getPoints()
	local x, y = path:getTopLeftCorner()
	utils.shiftPoints(points, x, y)
	for i,triangle in ipairs(love.math.triangulate(points)) do
		love.graphics.polygon("fill", triangle)
	end
	love.graphics.setCanvas()
	local imageData = canvas:newImageData()
	local image = love.graphics.newImage(imageData)
	
	usebatch.sprite = love.graphics.newSpriteBatch(image)

	self.__index = self
	setmetatable(usebatch, self)

	return usebatch

end

function UseBatch:addUse(use)
	table.insert(self.uses, use)
	local x, y = self.path:getTopLeftCorner()
	local rotate = 0 
	if use.transform then
		if use.transform[1] == "translate" then
			print("hello")
			x = x + use.transform[2]
			y = y + use.transform[3]
		elseif use.transform[1] == "rotate" then
			rotate = use.transform[2] / 360 * 2 * math.pi
			local dx = x - use.transform[3]
			local dy = y - use.transform[4]
			local hypotenuse = math.sqrt(dx * dx + dy * dy)
			rotateInitial = math.atan(dy, dx)
			rotateFinal = rotateInitial + rotate
			x = x + hypotenuse * math.cos(rotateFinal)
			y = y + hypotenuse * math.sin(rotateFinal)
		end
	end
	self.sprite:add(x, y, rotate)
end

function UseBatch:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.sprite)
end

return UseBatch
