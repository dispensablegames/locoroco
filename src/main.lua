local Menu = require("menu")
local Game = require("game")

function love.load()
	love.window.setMode(1000, 1000, {vsync=true})
	menu = Menu:init()
	
	state = Game:init("world1level1.svg")
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

