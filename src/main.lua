local Menu = require("menu")
local Game = require("game")

function love.load()
	love.window.setMode(1000, 1000, {vsync=true})
	menu = Menu:init()
	
	state = menu
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

function love.mousepressed(x, y, button)
	state:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	state:mousereleased(x, y, button)
end
