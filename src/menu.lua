local Game = require("game")
local Drawing = require("drawing")

local utils = require("utils")

local Menu = {}

function Menu:init()
	local menu = {}
	menu.activeButtons = {}

	self.__index = self
	setmetatable(menu, self)

	local logo = love.graphics.newImage(Drawing:init("src/assets/logo.svg", 96 / 25.4):toImageData())

	menu.root = { 
		children = {
			newImageElement(logo),
			{ children = {} } 
		}
	}

	for i,file in ipairs(love.filesystem.getDirectoryItems("levels")) do
		local button = newTextElement(file, 10, function() menu:startGame(file) end)
		table.insert(menu.root.children[2].children, button)
	end

	menu.doc = {}

	renderNode(menu.root, menu.doc, 30, 20, 40)

	menu.game = nil

	return menu
end

function renderNode(node, doc, padding, x, y)
	if node.children then
		local nextY = y
		local lastY = nil
		for key,child in pairs(node.children) do
			if child.x then
				renderNode(child, doc, padding, x + child.x, y + child.x)
			else
				lastY = renderNode(child, doc, padding, x, nextY)
				nextY = lastY + padding
			end
		end
		return lastY or nextY
	else
		if node.text then
			local font = love.graphics.newFont()
			local contents = love.graphics.newText(font, node.text)
			local width = contents:getWidth()
			local height = contents:getHeight()
			local internalPadding = node.padding
			local rectangle = { x, y, x + width + 2 * internalPadding, y, x + width + 2 * internalPadding, y + height + 2 * internalPadding, x, y + height + 2 * internalPadding }
			local renderedNode = { 
				contents = contents, 
				rectangle = rectangle, 
				textoffset = { x + internalPadding, y + internalPadding },
				callback = node.callback, 
				background = node.background,
				color = node.color
			}
			table.insert(doc, renderedNode)
			return rectangle[6]
		else 
			local image = node.image
			local position = { x, y }
			local renderedNode = {
				image = image,
				position = position,
				rectangle = { x, y, x + image:getWidth(), y, x + image:getWidth(), y + image:getHeight(), x, y + image:getHeight() }
			}
			table.insert(doc, renderedNode)
			return y + image:getHeight()
		end
	end
end

function newTextElement(text, padding, callback)
	return { 
		text = text,
		callback = callback,
		padding = padding,
		background = { 1, 0, 0 },
		color = { 0, 0, 0 }
	}
end

function newImageElement(image, callback)
	return {
		image = image,
		callback = callback
	}
end

function drawDoc(doc)
	for key,element in pairs(doc) do
		if element.contents then
			love.graphics.setColor(element.background)
			love.graphics.polygon("fill", element.rectangle)
			love.graphics.setColor(element.color)
			love.graphics.draw(element.contents, unpack(element.textoffset))
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(element.image, unpack(element.position))
		end

	end
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
	drawDoc(self.doc)
end

function Menu:keyreleased(key)
end

function Menu:mousereleased(x, y, mousebutton)
	for i,e in ipairs(self.doc) do
		if inRectangle(e.rectangle, x, y) then
			if e.callback then
				e.callback()
				return
			end
		end
	end
end

function Menu:mousepressed()
end

function inRectangle(rectangle, x, y)
	return x >= rectangle[1] and x <= rectangle[5] and y >= rectangle[2] and y <= rectangle[6]
end

return Menu
