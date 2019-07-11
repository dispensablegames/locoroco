Path = {}

function Path:init(pathDef, style, fill)
	local path = {}
	path.commands = pathDef
	path.style = style
	path.fill = fill
	path.points = nil

	self.__index = self
	setmetatable(path, self)

	path:makeTable()
	path:clarify()

	path:parseStyles()

	return path
end

function Path:getPoints() 
	return self.points
end

function Path:parseStyles()
	local newStyles = {}
	for key,val in string.gmatch(self.style, "([^:]+):([^;]+);?") do
		newStyles[key] = val
	end
	self.style = newStyles
end

-- converts path definition into nice table of commands
function Path:makeTable()
	local newCommands = {}
	for str in string.gmatch(self.commands, "[^%s,]+") do
		if string.find(str, "%a") == 1 then
			local command = { str }
			table.insert(newCommands, command)
		else
			table.insert(newCommands[#newCommands], str)
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
			for k,point in ipairs(bezierCurveRemoveEndpoints(love.math.newBezierCurve(lastX, lastY, unpack(command, 2)):render(2))) do
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

return Path
