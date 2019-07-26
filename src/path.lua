local utils = require("utils")
Path = {}

function Path:init(attributes, tags, adjust)
	local path = {}
	path.commands = attributes.d
	if attributes.id then
		path.id = attributes.id
	end
	if attributes.style then
		path.style = attributes.style
	else
		path.style = {}
	end

	path.tags = tags

	self.__index = self
	setmetatable(path, self)

	path:parseStyles()

	for key,val in pairs(attributes) do
		if key ~= "style" and key ~= "d" and key ~= "id" then
			path.style[key] = val
		end
	end

	path.points = nil

	path.boundingBox = nil
	path.center = nil
	path.width = nil
	path.height = nil


	path:makeTable(adjust)
	path:clarify()


	return path
end

function Path:getId()
	return self.id
end

function Path:getPoints() 
	return self.points
end

function Path:getStyle(key)
	return self.style[key]
end

function Path:getBoundingBox()
	return unpack(self.boundingBox)
end

function Path:getTopLeftCorner()
	return self.boundingBox[1], self.boundingBox[2]
end

function Path:getCenter()
	return unpack(self.center)
end

function Path:getWidth()
	return self.width
end

function Path:getHeight()
	return self.height
end

function Path:tagged(tag)
	for i,val in ipairs(self.tags) do
		if val == tag then
			return true
		end
	end
	return false
end

function Path:parseStyles()
	self.style = utils.parseStyles(self.style)
end

-- converts path definition into nice table of commands
function Path:makeTable(adjust)
	local newCommands = {}
	for str in string.gmatch(self.commands, "[^%s,]+") do
		if string.find(str, "%a") == 1 then
			local command = { str }
			table.insert(newCommands, command)
		else
			table.insert(newCommands[#newCommands], tonumber(str) * adjust)
		end
	end
	self.commands = newCommands
end

-- makes some commands more explicit
function Path:clarify()
	local commands = self.commands
	local newCommands = {}
	for i,command in ipairs(commands) do
		local newCommand = {}
		if command[1] == "M"  and #command > 3 then
			table.insert(newCommands, { "M", command[2], command[3] })
			newCommand = { "L" }
			for k=4,#command do
				table.insert(newCommand, command[k])
			end
			table.insert(newCommands, newCommand)
		elseif command[1] == "m"  and #command > 3 then
			table.insert(newCommands, { "m", command[2], command[3] })
			newCommand = { "l" }
			for k=4,#command do
				table.insert(newCommand, command[k])
			end
			table.insert(newCommands, newCommand)
		elseif command[1] == "C" and #command > 7 then
			for k=2,#command,6 do
				newCommand = { "C", unpack(command, k, k + 5) }
				table.insert(newCommands, newCommand)
			end
		elseif command[1] == "c" and #command > 7 then
			for k=2,#command,6 do
				newCommand = { "c", unpack(command, k, k + 5) }
				table.insert(newCommands, newCommand)
			end
		else
			table.insert(newCommands, command)
		end
	end
	self.commands = newCommands
end

-- convert table of commands into table of absolute commands
function Path:makeAbsolute(lastX, lastY)
	local commands = self.commands
	for j,command in ipairs(commands) do
		if not (command[1] == "Z" or command[1] == "z") then
			if command[1] == "v" then
				command[1] = "L"
				command[3] = lastY + command[2] 
				command[2] = lastX
				lastX = command[2]
				lastY = command[3]
			elseif command[1] == "V" then
				command[1] = "L"
				command[3] = command[2]
				command[2] = lastX
				lastX = command[2]
				lastY = command[3]
			elseif command[1] == "h" then
				command[1] = "L"
				command[2] = command[2] + lastX
				command[3] = lastY
				lastX = command[2]
				lastY = command[3]
			elseif command[1] == "H" then
				command[1] = "L"
				command[3] = lastY
				lastX = command[2]
				lastY = command[3]
			elseif string.find(command[1], "[m%u]") == 1 then
				lastX = command[#command - 1]
				lastY = command[#command]
			elseif command[1] == "c" then
				command[1] = string.upper(command[1])
				for k = 2,#command - 1,2 do
					command[k] = command[k] + lastX
					command[k + 1] = command[k + 1] + lastY
				end
				lastX = command[#command - 1]
				lastY = command[#command]
			else 
				command[1] = string.upper(command[1])
				for k = 2,#command - 1,2 do
					command[k] = command[k] + lastX
					command[k + 1] = command[k + 1] + lastY
					lastX = command[k]
					lastY = command[k + 1]
				end
			end
		end	
	end
	return lastX, lastY
end

function bezierCurveRemoveEndpoints(curve)
	if curve[1] == curve[3] and curve[2] == curve[4] then
		table.remove(curve, 1)
		table.remove(curve, 1)
	end
	if curve[#curve - 3] == curve[#curve - 1] and curve[#curve - 2] == curve[#curve] then
		table.remove(curve, #curve)
		table.remove(curve, #curve)
	end
	return curve
end

function Path:pointify()
	local commands = self.commands
	local points = {}
	local firstX = commands[1][2]
	local firstY = commands[1][3]
	local lastX = 0
	local lastY = 0
	for j,command in ipairs(commands) do
		if command[1] == "M" or command[1] == "m" then
			lastX = command[2]
			lastY = command[3]
			table.insert(points, lastX)
			table.insert(points, lastY)
		elseif command[1] == "L" then
			for k=2,#command do
				table.insert(points, command[k])
			end
			lastX = command[#command - 1]
			lastY = command[#command]
		elseif command[1] == "C" then
			table.remove(points, #points)
			table.remove(points, #points)
			for k,point in ipairs(bezierCurveRemoveEndpoints(love.math.newBezierCurve(lastX, lastY, unpack(command, 2)):render(3))) do
				table.insert(points, point)
			end
			lastX = command[#command - 1]
			lastY = command[#command]
		end
	end
	if points[1] == points[#points - 1] and points[2] == points[#points] then
		table.remove(points, #points)
		table.remove(points, #points)
	end
	self.points = points
end

function Path:metadataSet()
	local points = self.points
	local minX = points[1]
	local minY = points[2]
	local maxX = points[1]
	local maxY = points[2]
	for i=1,#points-1,2 do
		if points[i] > maxX then
			maxX = points[i]
		end
		if points[i] < minX then
			minX = points[i]
		end
		if points[i + 1] > maxY then
			maxY = points[i + 1]
		end
		if points[i + 1] < minY then
			minY = points[i + 1]
		end
	end
	self.boundingBox = { minX, minY, maxX, minY, maxX, maxY, minX, maxY }
	self.center = { (minX + maxX) / 2, (minY + maxY) / 2 }
	self.width = maxX - minX
	self.height = maxY - minY
end

return Path
