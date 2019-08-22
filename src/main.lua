local Menu = require("menu")
local Game = require("game")
local ResultScreen = require("resultscreen")

function love.load()
	love.window.setTitle("LocoRoco")
	love.window.setMode(500, 500, {vsync=true, resizable=true})
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

function love.mousemoved(x, y)
	state:mousemoved(x, y)
end

function love.resize()
	state:resize()
end
