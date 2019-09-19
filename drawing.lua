local xml2lua = require("xml2lua")
--Uses a handler that converts the XML to a Lua table
local tree = require("xmlhandler.tree")
local Path = require("path")
local Use = require("use")

Drawing = {}

function Drawing:init(filename, adjust)
	local drawing = {}
	drawing.paths = {}
	drawing.uses = {}
	drawing.adjust = adjust or 1

	self.__index = self
	setmetatable(drawing, self)

	drawing:importSvg(filename)

	drawing:convertPaths()

	local minX, minY = drawing.paths[1]:getTopLeftCorner()
	local maxX, maxY = drawing.paths[1]:getBottomRightCorner()
	for i,path in ipairs(drawing.paths) do
		local x, y = path:getTopLeftCorner()
		if x < minX then
			minX = x
		end
		if y < minY then
			minY = y
		end
		x, y = path:getBottomRightCorner()
		if x > maxX then
			maxX = x
		end
		if y > maxY then
			maxY = y
		end
	end

	drawing.boundingBox = { minX, minY, maxX, minY, maxX, maxY, minX, maxY }
	drawing.width = maxX - minX
	drawing.height = maxY - minY

	return drawing
end

function Drawing:getPaths() 
	return self.paths
end

function Drawing:getUses()
	return self.uses
end

function Drawing:getWidth()
	return self.width
end

function Drawing:getHeight()
	return self.height
end

function Drawing:getTopLeftCorner()
	return self.boundingBox[1], self.boundingBox[2]
end

function Drawing:getPath(id)
	for i,path in ipairs(self.paths) do
		if path:getId() == id then
			return path
		end
	end
	return nil
end

function Drawing:toImageData()
	local offsetX, offsetY = self:getTopLeftCorner(self.width, self.height)
	local canvas = love.graphics.newCanvas(self.width, self.height)
	for i,path in ipairs(self.paths) do
		local imageData = path:toImageData()
		local image = love.graphics.newImage(imageData)
		love.graphics.setCanvas(canvas)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setBlendMode("alpha", "premultiplied")
		local x, y = path:getTopLeftCorner()
		love.graphics.draw(image, x - offsetX, y - offsetY)
	end
	love.graphics.setCanvas()
	local imageData = canvas:newImageData()
	return imageData
end

-- takes out all paths from svg node, deep search
function Drawing:extractNodes(node, tags)
	for key,val in pairs(node) do 
		if key == "path" then
			if val._attr then 
				local path = Path:init(val._attr, tags, self.adjust)
				table.insert(self.paths, path)
			else
				for i,p in ipairs(val) do
					local path = Path:init(p._attr, tags, self.adjust)
					table.insert(self.paths, path)
					end
			end
		elseif key == "use" then
			if val._attr then
				local use = Use:init(val._attr, tags, self.adjust)
				table.insert(self.uses, use)
			else 
				for i,u in ipairs(val) do
					local use = Use:init(u._attr, tags, self.adjust)
					table.insert(self.uses, use)
					end
				end
		elseif key == "g" then
			if val._attr then
				local newTags = tableCopy(tags)
				if val._attr.id then
					table.insert(newTags, val._attr.id)
				end
				self:extractNodes(val, newTags)
			else 
				for i,g in ipairs(val) do
					local newTags = tableCopy(tags)
					if g._attr.id then
						table.insert(newTags, g._attr.id)
					end
					self:extractNodes(g, newTags)
				end
			end
		end
	end
end

function tableCopy(t1)
	local t2 = {}
	for i,val in ipairs(t1) do
		table.insert(t2, val)
	end
	return t2
end
		
	
function Drawing:convertPaths()
	local lastX = 0
	local lastY = 0
	for i,path in ipairs(self.paths) do
		lastX, lastY = path:makeAbsolute(lastX, lastY)
	end
	for i,path in ipairs(self.paths) do 
		path:pointify()
		path:metadataSet()
	end
end

function Drawing:importSvg(filename)
	local handler = tree:new()
	local parser = xml2lua.parser(handler)

	local svg = io.open(filename, "r")
	local svgContents = svg:read("*all")
	parser:parse(svgContents)

	local root = handler.root.svg

	self:extractNodes(root, {})

	svg:close()
end

return Drawing
