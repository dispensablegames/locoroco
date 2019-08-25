Fruit = {}

function Fruit:init(world, x, y, id, frames)
	local detectionRadius = 30
	local finishedFruit = {}
	
	finishedFruit.state_ = "uneaten"

	finishedFruit.body_ = love.physics.newBody(world, x, y, "static")
	finishedFruit.shape_ = love.physics.newRectangleShape(50, 200)
	finishedFruit.fixture_ = love.physics.newFixture(finishedFruit.body_, finishedFruit.shape_)
	finishedFruit.fixture_:setUserData({name = "fruit", parent = finishedFruit})
	finishedFruit.fixture_:setSensor(true)

	finishedFruit.frames_ = frames

	finishedFruit.animationState_ = 0

	self.__index = self
	setmetatable(finishedFruit, self)

	return finishedFruit
end

function Fruit:update()
	if self.state_ == "uneaten" then
		for i, contact in pairs(self.body_:getContacts()) do
			local fixture1, fixture2 = contact:getFixtures()
			local userData1 = fixture1:getUserData()
			local userData2 = fixture2:getUserData()
			if userData1.name == "circle" then
				self.state_ = "eaten"
				return userData1.parent
			elseif userData2.name == "circle" then
				self.state_ = "eaten"
				return userData2.parent	
			end
		end
	end
end

function Fruit:draw()	
	love.graphics.setColor(1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")
	local x, y = self.body_:getPosition()

	local xshear = math.sin(self.animationState_)/8
	local yscale = -math.abs(math.cos(self.animationState_*2))/6 + 1

	if self.state_ == "eaten" then
		love.graphics.draw(self.frames_[2].image, x, y, 0, 1, yscale, self.frames_[2].width/2, self.frames_[2].height, xshear)
	else
		love.graphics.draw(self.frames_[1].image, x, y, 0, 1, yscale, self.frames_[1].width/2, self.frames_[1].height, xshear)
	end
	self.animationState_ = self.animationState_ + 0.05

	love.graphics.polygon("fill", self.body_:getWorldPoints(self.shape_:getPoints()))
end

return Fruit