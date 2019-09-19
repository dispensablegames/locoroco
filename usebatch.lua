local utils = require("utils")

local UseBatch = {}

function UseBatch:init(path)
	local usebatch = {}
	usebatch.path = path
	usebatch.uses = {}

	local imageData = path:toImageData()
	local image = love.graphics.newImage(imageData)
	
	usebatch.sprite = love.graphics.newSpriteBatch(image)

	self.__index = self
	setmetatable(usebatch, self)


	return usebatch

end

function UseBatch:addUse(use)
	table.insert(self.uses, use)
	local px, py = self.path:getTopLeftCorner()
	local x, y = self.path:getTopLeftCorner()
	local rotate = 0 
	if use.transform then
		if use.transform[1] == "translate" then
			x = x + use.transform[2]
			if use.transform[3] then
				y = y + use.transform[3]
			end
		elseif use.transform[1] == "rotate" then
			rotate = use.transform[2] / 360 * 2 * math.pi
			local ox = use.transform[3]
			local oy = use.transform[4]
			local dx = x - ox
			local dy = y - oy
			rotateInitial = utils.quadAwareATan(dy, dx)
			rotateFinal = rotateInitial + rotate
			local hypotenuse = math.sqrt(dx * dx + dy * dy)
			x = ox + hypotenuse * math.cos(rotateFinal)
			y = oy + hypotenuse * math.sin(rotateFinal)
		end
	end
	self.sprite:add(x, y, rotate)
end


function UseBatch:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.sprite)
end

return UseBatch
