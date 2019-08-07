Fruit = {}

function Fruit:init(world, x, y, id)
	local detectionRadius = 30
	local finishedFruit = {}
	
	finishedFruit.state_ = "uneaten"
	finishedFruit.animationState = 0

	finishedFruit.body_ = love.physics.newBody(world, x, y, "static")
	finishedFruit.shape_ = love.physics.newCircleShape(detectionRadius)
	finishedFruit.fixture_ = love.physics.newFixture(finishedFruit.body_, finishedFruit.shape_)

	finishedFruit.fixture_:setUserData({name = "fruit", parent = finishedFruit})
	finishedFruit.fixture_:setSensor(true)

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
	love.graphics.setColor(0, 0, 0)
	local x, y = self.body_:getPosition()
	if self.state_ == "eaten" then
		love.graphics.circle("line", x, y, 30)
	else
		love.graphics.circle("fill", x, y, 30)
	end
end

return Fruit