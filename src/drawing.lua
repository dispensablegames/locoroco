local xml2lua = require("xml2lua")
--Uses a handler that converts the XML to a Lua table
local handler = require("xmlhandler.tree")
local Path = require("path")

Drawing = {}

function Drawing:init(filename)
	local drawing = {}
	drawing.paths = {}

	self.__index = self
	setmetatable(drawing, self)

	drawing:importSvg(filename)

	drawing:convertPaths()

	return drawing
end

function Drawing:getPaths() 
	return self.paths
end

-- takes out all paths from svg node, deep search
function Drawing:extractPaths(node, tags)
	for key,val in pairs(node) do 
		if key == "path" then
			if val._attr then 
				local path = Path:init(val._attr, tags)
				table.insert(self.paths, path)
			else
				for i,p in ipairs(val) do
					local path = Path:init(p._attr, tags)
					table.insert(self.paths, path)
					end
			end
		elseif key == "g" then
			if val._attr then
				local newTags = tableCopy(tags)
				if val._attr.id then
					table.insert(newTags, val._attr.id)
				end
				self:extractPaths(val, newTags)
			else 
				for i,g in ipairs(val) do
					local newTags = tableCopy(tags)
					if g._attr.id then
						table.insert(newTags, g._attr.id)
					end
					self:extractPaths(g, newTags)
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
	end
end

function Drawing:importSvg(filename)
	local parser = xml2lua.parser(handler)

	local svg = io.open(filename, "r")
	local svgContents = svg:read("*all")
	parser:parse(svgContents)

	local root = handler.root.svg

	self:extractPaths(root, {})
end

return Drawing
