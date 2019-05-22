local xml2lua = require("xml2lua")
--Uses a handler that converts the XML to a Lua table
local handler = require("xmlhandler.tree")

local parser = xml2lua.parser(handler)

local svg = io.open("test.svg", "r")
local svgContents = svg:read("*all")
parser:parse(svgContents)

local paths = {}
local root = handler.root.svg

function extractPaths(node, arr)
	for key,val in pairs(node) do 
		if key == "path" then
			if type(val) == "table" then 
				for i,path in ipairs(val) do
					table.insert(arr, path._attr.d)
				end
			else 
				table.insert(arr, val._attr.d)
			end
		elseif key == "g" then
			extractPaths(val, arr)
		end
	end
end

extractPaths(root, paths)

for i,path in ipairs(paths) do
	print(path)
end

local pathsConverted = {}

function convertPaths(paths, arr)
	for i,path in ipairs(paths) do
		local newPath = {}
		for str in string.gmatch(path, "[^%s,]+") do
			if string.find(str, "%a") == 1 then
				local command = { str }
				table.insert(newPath, command)
			else
				table.insert(newPath[#newPath], str)
			end
		end
		table.insert(arr, newPath)
	end
end

convertPaths(paths, pathsConverted)

xml2lua.printable(pathsConverted)
