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

return utils
