local Drawing = require("drawing")

local utils = require("utils")

local Menu = {}

function Menu:init()
	local menu = {}
	menu.activeButtons = {}

	self.__index = self
	setmetatable(menu, self)

	local logo = love.graphics.newImage(Drawing:init("assets/logo.svg", 96 / 25.4):toImageData())

	menu.root = { 
		children = {
			newImageElement(logo, true),
			{ children = {}, paddingY = 10, paddingX = 0 }
		}
	}

	for i,file in ipairs(love.filesystem.getDirectoryItems("levels")) do
		local button = newTextElement(file, 10, function() menu:startGame(file) end)
		table.insert(menu.root.children[2].children, button)
	end

	menu.doc = {}

	menu:renderRoot()

	menu.game = nil

	return menu
end

function Menu:renderRoot()
	self.doc = {}
	renderNode(self.root, self.doc, 0, 0, 50, 50)
end

function renderNode(node, doc, x, y, paddingX, paddingY)
	local paddingX = paddingX or 0
	local paddingY = paddingY or 0 
	if node.children then
		local nextY = y + paddingY
		local lastY = nil
		for key,child in pairs(node.children) do
			if child.x then
				renderNode(child, doc, x + child.x, y + child.x)
			else
				if child.padding then
					lastY = renderNode(child, doc, x + paddingX, nextY, child.padding, child.padding)
				elseif child.paddingX then
					lastY = renderNode(child, doc, x + paddingX, nextY, child.paddingX, child.paddingY)
				else 
					lastY = renderNode(child, doc, x + paddingX, nextY)
				end
				nextY = lastY + paddingY
			end
		end
		return lastY or nextY
	else
		if node.text then
			local font = love.graphics.newFont(16)
			local contents = love.graphics.newText(font, node.text)
			local width = contents:getWidth()
			local height = contents:getHeight()
			local internalPadding = node.padding or 0
			local position = nil
			if node.centered then
				local windowwidth = love.graphics.getWidth()
				position = { windowwidth / 2 - width / 2, y }
			else
				position = { x, y }
			end	
			local rectangle = { position[1], position[2], position[1] + width + 2 * internalPadding, position[2], position[1] + width + 2 * internalPadding, position[2] + height + 2 * internalPadding, position[1], position[2] + height + 2 * internalPadding }
			local renderedNode = { 
				contents = contents, 
				rectangle = rectangle, 
				textoffset = { position[1] + internalPadding, position[2] + internalPadding },
				callback = node.callback, 
				curbackground = node.background,
				normalbackground = node.background,
				hoverbackground = node.hoverbackground or node.background,
				curcolor = node.color,
				normalcolor = node.color,
				hovercolor = node.hovercolor or node.color,
			}
			table.insert(doc, renderedNode)
			return rectangle[6]
		else 
			local image = node.image
			local position = nil
			if node.centered then
				local windowwidth = love.graphics.getWidth()
				position = { windowwidth / 2 - image:getWidth() / 2, y }
			else
				position = { x, y }
			end	
			local renderedNode = {
				image = image,
				position = position,
				rectangle = { position[1], position[2], position[1] + image:getWidth(), position[2], position[1] + image:getWidth(), position[2] + image:getHeight(), position[1], position[2] + image:getHeight() }
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
		hoverbackground = { 1, 1, 0 },
		color = { 0, 0, 0 },
		centered = true
	}
end

function newImageElement(image, centered, callback)
	return {
		image = image,
		centered = centered,
		callback = callback
	}
end

function drawDoc(doc)
	for key,element in pairs(doc) do
		if element.contents then
			love.graphics.setColor(element.curbackground)
			love.graphics.polygon("fill", element.rectangle)
			love.graphics.setColor(element.curcolor)
			love.graphics.draw(element.contents, unpack(element.textoffset))
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(element.image, unpack(element.position))
		end

	end
end

function Menu:startGame(filename)
	print("STARTING GAME")
	self.game = filename
end

function Menu:update()
	if self.game then
		return {"Game", {self.game}}
	end
end

function Menu:draw()
	love.graphics.setBackgroundColor(1, 1, 1)
	drawDoc(self.doc)
end

function Menu:keyreleased(key)
end

function Menu:mousemoved(x, y)
	for i,e in ipairs(self.doc) do
		if inRectangle(e.rectangle, x, y) then
			e.curcolor = e.hovercolor
			e.curbackground = e.hoverbackground
		else
			e.curcolor = e.normalcolor
			e.curbackground = e.normalbackground
		end
	end
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

function Menu:resize()
	self:renderRoot()
end

function inRectangle(rectangle, x, y)
	return x >= rectangle[1] and x <= rectangle[5] and y >= rectangle[2] and y <= rectangle[6]
end

return Menu
