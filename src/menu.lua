local Game = require("game")
local Menu = {}

function Menu:init()
	local menu = {}
	menu.levels = {}

	for i,file in ipairs(love.filesystem.getDirectoryItems("levels")) do
		table.insert(menu.levels, file)
	end

	self.game = nil

	self.__index = self
	setmetatable(menu, self)
	return menu
end

function Menu:update()
	if self.game then
		return self.game
	end
end

function Menu:draw()
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.setColor(0,0,0)
	for i,level in ipairs(self.levels) do
		print("hello")
		love.graphics.print(level, 0, i * 20)
	end
end

function Menu:keyreleased(key)
	self.game = Game:init("world1level1.svg")
end

return Menu
