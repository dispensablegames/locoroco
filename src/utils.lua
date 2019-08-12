utils = {}

--[[
         |
         | -y
-x ------------- +x 
         | +y
         |
]]--

function utils.quadAwareATan(dy, dx)
	local angle = math.atan(math.abs(dy) / math.abs(dx))
	if dx >= 0 and dy >= 0 then
		return angle
	elseif dx <= 0 and dy >= 0 then
		return math.pi - angle
	elseif dx <=0 and dy <= 0 then
		return math.pi + angle
	elseif dx >= 0 and dy <= 0 then
		return 2 * math.pi - angle
	end
end

function utils.averagePoints(points)
	local xSum = 0
	local ySum = 0

	for i=1, #points, 2 do
		xSum = xSum + points[i]
		ySum = ySum + points[i + 1]
	end
	return xSum / (#points / 2), ySum / (#points / 2)
end

function utils.shiftPoints(points, x, y)
	local shiftedPoints = {}
	for i=1, #points, 2 do
		shiftedPoints[i] = points[i] - x
		shiftedPoints[i + 1] = points[i + 1] - y
	end
	return shiftedPoints
end

function utils.parseColor(color)
	local newColor = {}
	for val in string.gmatch(string.sub(color, 2), "..") do
		table.insert(newColor, tonumber(val, 16) / 255)
	end
	return newColor	
end

function utils.parseStyles(styles)
	if type(styles) == "table" then
		return styles
	end
	local newStyles = {}
	for key,val in string.gmatch(styles, "([^:]+):([^;]+);?") do
		newStyles[key] = val
	end
	return newStyles
end

function utils.getWorldPoints(body, shape)
	local shapePoints = {}

	local i = 1
	while true do
		if pcall(function() shape:getPoint(i) end) then
			local x, y = shape:getPoint(i)
			table.insert(shapePoints, x)
			table.insert(shapePoints, y)
		i = i + 1
		else
			break
		end
	end

	local points = {}
	for i = 1, #shapePoints, 2 do 
		local x, y = body:getWorldPoint(shapePoints[i], shapePoints[i + 1])
		table.insert(points, x)
		table.insert(points, y)
	end
	table.remove(points, #points)
	table.remove(points, #points)
	return points
end

-- polygons is a table of polygons
-- a polygon is a table with two keys, points and color
-- color is a table of 3 numbers 
-- points is a table of at least 3 points
-- width is the desired width of the image 
-- height is the desired height of the image
-- offsetX is the desired x offset of all polygons (optional, depends on shiftPoints, defaults to 0)
-- offsetY is the desired y offset of all polygons (optional, depends on shiftPoints, defaults to 0)
function utils.imageDataFromPolygons(polygons, width, height, offsetX, offsetY)
	local xoffset = offsetX or 0
	local yoffset = offsetY or 0
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas(canvas)
	for i,polygon in ipairs(polygons) do
		love.graphics.setColor(polygon.color)
		local points = polygon.points
		if xoffset or yoffset then
			points = utils.shiftPoints(points, xoffset, yoffset)
		end
		love.graphics.polygon("fill", points)
	end
	love.graphics.setCanvas()
	local imageData = canvas:newImageData()
	return imageData
end

function utils.tableAppendFunky(table1, table2)
	if table1 == nil then
		return table1
	elseif table2 == nil then
		return table2
	end
	for key,value in pairs(table2) do
		table1[key] = value
	end
end

function utils.jenkins(pointTable) 
	local returnTable = getRightmostPoint(pointTable)
	local x1, y1 = unpack(returnTable)
	local xOrig = x1
	local yOrig = y1

	while true do
		local newX, newY = findJenkins(x1, y1, pointTable) 

		if newX == xOrig and newY == yOrig then
			return returnTable
		else

			table.insert(returnTable, newX)
			table.insert(returnTable, newY)
			x1 = newX
			y1 = newY
		end
	end
end

function findJenkins(x1, y1, pointTable)
	
	for i = 1, #pointTable do
		local x2 = pointTable[2*i - 1]
		local y2 = pointTable[2*i]

		local correctPoint = checkJenkins(x1, y1, x2, y2, pointTable)
		
		if correctPoint then
			return x2, y2
		end
	end
end

function checkJenkins(x1, y1, x2, y2, pointTable)
		if x1 == x2 and y1 == y2 then
			return false
		end
			local correctPoint = true

			for i =1, #pointTable/2 do
				local x3 = pointTable[2*i - 1]
				local y3 = pointTable[2*i]
				if (x3 ~= x1 or y3 ~= y1) and (x3~= x2 or y3 ~= y2) then
					if utils.orientation(x1, y1, x2, y2, x3, y3) == "clockwise" then
						correctPoint = false
					end
				end
			end
		return correctPoint
end
function getRightmostPoint(pointTable)
	local x = pointTable[1]
	local y = pointTable[2]
	for i = 1, #pointTable/2 do
		if pointTable[2*i - 1] > x then
			x = pointTable[2*i - 1]
			y = pointTable[2*i]
		end
	end
	return {x, y}
end

function utils.orientation(ax, ay, bx, by, cx, cy)
	local val = (by - ay) * (cx - bx) - (bx - ax) * (cy - by)
	if val == 0 then
		return "colinear"
	elseif val > 0 then
		return "clockwise"
	else
		return "counterclockwise"
	end
end

function utils.evenlyDistributePoints(points, n)
	local totalLength = getTotalLengthOfPolygon(points)
	local unitLength = totalLength/n
	local angles = {}
	local resultPoints = {}

	local lengthLeft = unitLength

	local i = 2
	local x1 = points[1]
	local y1 = points[2]
	local x2 = points[3]
	local y2 = points[4]
	table.insert(resultPoints, x1)
	table.insert(resultPoints, y1)
	table.insert(angles, math.pi/2)

	while #resultPoints < 2*n and i <= #points/2 do
		local lineLength = math.sqrt((y2-y1)*(y2-y1)+ (x2-x1)*(x2-x1))

		if lineLength > lengthLeft then
			local angle = utils.quadAwareATan(y2-y1, x2-x1)
			local newX = x1 + math.cos(angle)*lengthLeft
			local newY = y1 + math.sin(angle)*lengthLeft
			x1 = newX
			y1 = newY
			table.insert(resultPoints, newX)
			table.insert(resultPoints, newY)
			table.insert(angles, angle)
			lengthLeft = unitLength
		else 
			lengthLeft = lengthLeft - lineLength
			i = i + 1
			x1 = points[2*i - 3]
			y1 = points[2*i - 2]
			x2 = points[2*i - 1]
			y2 = points[2*i]
		end
	end

	x1 = points[#points - 1]
	y1 = points[#points]
	x2 = points[1]
	y2 = points[2]

	lineLength = math.sqrt((y2-y1)*(y2-y1)+ (x2-x1)*(x2-x1))

	while #resultPoints < 2*n and lineLength > lengthLeft do
		local angle = utils.quadAwareATan(y2-y1, x2-x1)
		local newX = x1 + math.cos(angle)*lengthLeft
		local newY = y1 + math.sin(angle)*lengthLeft
		x1 = newX
		y1 = newY
		table.insert(resultPoints, newX)
		table.insert(resultPoints, newY)
		table.insert(angles, angle)
		lengthLeft = unitLength

		lineLength = math.sqrt((y2-y1)*(y2-y1)+ (x2-x1)*(x2-x1))
	end

	if resultPoints[#resultPoints - 1] == resultPoints[1] and resultPoints[#resultPoints] == resultPoints[2] then
		print("uh oh")
		table.remove(resultPoints, #resultPoints)
		table.remove(resultPoints, #resultPoints)
		table.remove(angles, #angles)
	end

	return resultPoints, angles
end



function getTotalLengthOfPolygon(points)
	local total = 0
	for i =2, #points/2 do
		local x1 = points[2*i -3]
		local y1 = points[2*i-2]
		local x2 = points[2*i - 1]
		local y2 = points[2*i]
		total = total + math.sqrt((y2-y1)*(y2-y1)+ (x2-x1)*(x2-x1))
	end
	local xF = points[1]
	local yF = points[2]
	local xI = points[#points - 1]
	local yI = points[#points]
	return total + math.sqrt((yF-yI)*(yF-yI)+ (xF-xI)*(xF-xI))
end

return utils
