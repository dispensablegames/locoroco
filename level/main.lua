local polygons = {}
local current = 1

function love.load()
	love.graphics.setBackgroundColor(255, 255, 255)
	zoom = 1
	cameraX = 0
	cameraY = 0
end

function love.update(dt)
	for i,v in ipairs(polygons) do
		for j,w in ipairs(v) do
			print(w)
		end
		print("\n")
	end
end

function love.wheelmoved(x,y)
	local old = zoom
	zoom = zoom + y / 10
	if zoom < 0.1 then
		zoom = old
	end
end

function love.mousemoved(x, y, dx, dy)
	if love.mouse.isDown(3) then
		cameraX = cameraX + dx
		cameraY = cameraY + dy
	end
end
		
function love.mousereleased(x, y, button)
	x, y = love.graphics.inverseTransformPoint(x, y)
	if button == 1 then
		if not polygons[current] then	
			polygons[current] = { x, y }
		else
			table.insert(polygons[current], x)
			table.insert(polygons[current], y)
		end
	elseif button == 2 then
		if polygons[current] then
			current = current + 1
		end
	end
end

function love.keyreleased(key)
	if key == "s" then
		export()
		print("pressed")
	end
end

function love.draw()
	local x, y = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()

	love.graphics.translate(cameraX / zoom, cameraY / zoom)

	love.graphics.translate(x, y)
	love.graphics.scale(zoom, zoom)
	love.graphics.translate(-x, -y )


	

	love.graphics.setColor(255, 0, 0)

	for i,polygon in ipairs(polygons) do 
		if (#polygon < 4) then
			for j=1,#polygon,2 do
				love.graphics.circle('fill', polygon[j], polygon[j + 1], 2)
			end
		elseif (#polygon < 6) then
			love.graphics.line(polygon)
		else
			love.graphics.polygon('fill', polygon)
		end
	end

	if polygons[current] then
		cur = polygons[current]
		love.graphics.line(cur[#cur - 1], cur[#cur], love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY()))
	end

end

function export()
	local file = io.open("level/level.loco", "w")
	for i,polygon in ipairs(polygons) do
		for i,point in ipairs(polygon) do
			file:write(point)
			file:write(" ")
		end
		file:write("\n")
	end
	file:close()
end
