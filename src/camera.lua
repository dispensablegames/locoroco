Camera = {}
Camera.x = 0
Camera.y = 0
Camera.scaleX = 1
Camera.scaleY = 1
Camera.rotation = 0

function Camera:set(locoX, locoY)
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	love.graphics.push()
	love.graphics.translate(width / 2, height / 2)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-width / 2, -height / 2)
	local distX = locoX - self.x
	local distY = locoY - self.y
	self:setPosition(self.x + distX / 15, self.y + distY / 15)
	love.graphics.translate(width / 2 - self.x, height / 2 - self.y)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:getTopLeftCorner()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	return self.x - width / 2, self.y - height / 2
end

function Camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function Camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function Camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Camera:setRotation(rotation)
	self.rotation = rotation
end

function Camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

return Camera
