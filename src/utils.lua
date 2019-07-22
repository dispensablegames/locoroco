utils = {}

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
	for i=1, #points, 2 do
		points[i] = points[i] - x
		points[i + 1] = points[i + 1] - y
	end
end

function utils.parseColor(color)
	local newColor = {}
	for val in string.gmatch(string.sub(color, 2), "..") do
		table.insert(newColor, tonumber(val, 16) / 255)
	end
	return newColor	
end
		
return utils
