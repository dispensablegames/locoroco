local Game = require("game")

local utils = require("utils")

local Menu = {}

function Menu:init()
	local menu = {}
	menu.activeButtons = {}

	self.__index = self
	setmetatable(menu, self)

	local lastY = 0
	for i,file in ipairs(love.filesystem.getDirectoryItems("levels")) do
		local button = newButton(file, 10, function() menu:startGame(file) end)
		local rectangleRendered = menu:placeButton(button, 10, lastY + 10)
		lastY = rectangleRendered[6]
	end

	menu.game = nil

	return menu
end

function newButton(text, padding, callback)
	local font = love.graphics.newFont()
	local button = {}
	local name = love.graphics.newText(font, text)
	button.name = name
	button.callback = callback
	local width = name:getWidth()
	local height = name:getHeight()
	button.width = name:getWidth()
	button.height = name:getHeight()
	button.rectangle = { 0, 0, width + 2 * padding, 0, width + 2 * padding, height + 2 * padding, 0, height + 2 * padding }
	button.textOffset = { padding, padding }
	return button
end

function Menu:placeButton(button, offsetX, offsetY)
	local bMeta = {}
	bMeta.button = button
	local rectangleRendered = utils.shiftPoints(button.rectangle, -offsetX, -offsetY)
	bMeta.rectangleRendered = rectangleRendered
	bMeta.textOffsetRendered = utils.shiftPoints(button.textOffset, -offsetX, -offsetY)
	table.insert(self.activeButtons, bMeta)
	return rectangleRendered
end

function drawButton(buttonInstance, buttonColor, textColor)
	love.graphics.setColor(buttonColor)
	love.graphics.polygon("fill", buttonInstance.rectangleRendered)
	love.graphics.setColor(textColor)
	love.graphics.draw(buttonInstance.button.name, unpack(buttonInstance.textOffsetRendered))
end

function Menu:startGame(filename)
	print("STARTING GAME")
	local game = Game:init(filename)
	self.game = game
end

function Menu:update()
	if self.game then
		return self.game
	end
end

function Menu:draw()
	love.graphics.setBackgroundColor(1, 1, 1)
	for i,buttonInstance in ipairs(self.activeButtons) do
		local background = {1, 0, 0}
		if inRectangle(buttonInstance.rectangleRendered, love.mouse.getPosition()) then
			background = {0, 1, 0}
		end
		drawButton(buttonInstance, background, {0, 0, 0})
	end
end

function Menu:keyreleased(key)
end

function Menu:mousereleased(x, y, mousebutton)
	for i,button in ipairs(self.activeButtons) do
		if inRectangle(button.rectangleRendered, x, y) then
			button.button.callback()
			return
		end
	end
end

function Menu:mousepressed()
end

function inRectangle(rectangle, x, y)
	return x >= rectangle[1] and x <= rectangle[5] and y >= rectangle[2] and y <= rectangle[6]
end

return Menu
