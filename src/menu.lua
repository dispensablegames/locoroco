local Game = require("game")

local utils = require("utils")

local Menu = {}

function Menu:init()
	local menu = {}
	menu.buttons = {}
	menu.buttonsDrawn = {}

	local font = love.graphics.newFont()

	for i,file in ipairs(love.filesystem.getDirectoryItems("levels")) do
		table.insert(menu.buttons, newButton(file, 40, function() menu:startGame(file) end))
	end

	self.game = nil

	self.__index = self
	setmetatable(menu, self)
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
	button.textOffset = { width + 2 * padding / 2 - width / 2, height + 2 * padding / 2 - height / 2 }
	return button
end

function Menu:drawButton(button, offsetX, offsetY)
	love.graphics.setColor(1, 0, 0)
	local newRectangle = utils.shiftPoints(button.rectangle, -offsetX, -offsetY)
	love.graphics.polygon("fill", newRectangle)
	love.graphics.setColor(0, 0, 0)
	love.graphics.draw(button.name, unpack(utils.shiftPoints(button.textOffset, -offsetX, -offsetY)))
	local bMeta = {}
	bMeta.button = button
	bMeta.rectangleRendered = newRectangle
	table.insert(self.buttonsDrawn, bMeta) 
	return newRectangle
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
	local lastY = 0
	local padding = 40
	for i,button in ipairs(self.buttons) do
		print(i)
		local drawn = self:drawButton(button, 40, lastY + 40)
		for i,point in ipairs(drawn) do
			print(point)
		end
		lastY = drawn[6]
		print()
	end
end

function Menu:keyreleased(key)
end

function Menu:mousereleased(x, y, mousebutton)
	for i,button in ipairs(self.buttonsDrawn) do
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
