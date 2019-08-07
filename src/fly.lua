Fly = {}

function Fly:init(world, x, y, id, frames)
	local detectionRadius = 30
	
	local finishedFly = {}
	
	finishedFly.state_ = "uncollected"
	finishedFly.animationState_ = love.math.random()
	finishedFly.frameState_ = 1
	finishedFly.targetLoco_ = nil
	finishedFly.id_ = id
	
	finishedFly.frames_ = frames

	finishedFly.body_ = love.physics.newBody(world, x, y, "static")
	finishedFly.shape_ = love.physics.newCircleShape(detectionRadius)
	finishedFly.fixture_ = love.physics.newFixture(finishedFly.body_, finishedFly.shape_)

	finishedFly.fixture_:setUserData({name="fly", parent=finishedFly})
	finishedFly.fixture_:setSensor(true)

	self.__index = self
	setmetatable(finishedFly, self)

	return finishedFly
end

function Fly:update()
	if self.state_ == "deleted" then
		return "delete"
	elseif self.state_ == "uncollected" then
		for i, contact in pairs(self.body_:getContacts()) do
			local fixture1, fixture2 = contact:getFixtures()
			local userData1 = fixture1:getUserData()
			local userData2 = fixture2:getUserData()
			if userData1.name == "circle" then
				self.state_ = "collected"
				self.targetLoco_ = userData1.parent
				self.animationState_ = 1
				return
			elseif userData2.name == "circle" then
				self.state_ = "collected"
				self.targetLoco_ = userData2.parent	
				self.animationState_ = 1
				return
			end
		end		
		local currentX, currentY = self.body_:getPosition()
		self.body_:setPosition(currentX, currentY + 0.6*math.sin(self.animationState_))
		self.animationState_ = self.animationState_ + 0.1
	elseif self.state_ == "collected" then
		if self.animationState_ <= 0 then
			self.state_ = "deleted"
		else
			local targetX, targetY = self.targetLoco_:getPosition()
			local selfX, selfY = self.body_:getPosition()
			self.body_:setPosition(selfX + (targetX - selfX)/3, selfY + (targetY - selfY)/3)
			self.animationState_ = self.animationState_ - 0.05
		end
	end		
	self.frameState_ = self.frameState_ + 1
	self.frameState_ = self.frameState_ % (#self.frames_ * 2)
end

function Fly:delete()
	self.body_:destroy()
end

function Fly:draw()
	if self.state_ == "deleted" then
		return
	end
	local x, y = self.body_:getPosition()

	love.graphics.setColor(1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")

	local picture = self.frames_[math.floor(self.frameState_ / 2) + 1]
	if self.state_ == "collected" then
		love.graphics.draw(picture.image, x, y, 1 - self.animationState_, self.animationState_)
	else
		print(self.frameState_)
		love.graphics.draw(picture.image, x - picture.width / 2, y - picture.height )
	end
end

return Fly
