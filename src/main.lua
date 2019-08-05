local Menu = require("menu")
local Game = require("game")

function love.load()
	menu = Menu:init()
	
	state = Game:init("test.svg")
end

function love.update(dt)
	local newState = state:update(dt)
	if newState then
		state = newState
	end
end

function love.draw()
	state:draw()
end

function love.keyreleased(key)
	state:keyreleased(key)
end

