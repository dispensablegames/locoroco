local Use = {}

function Use:init(attributes, tags, adjust)
	local use = {}
	if attributes["xlink:href"] then
		use.href = string.sub(attributes["xlink:href"], 2)
	end
	if attributes.href then
		use.href = string.sub(attributes.href, 2)
	end
	if attributes.transform then
		use.transform = parseTransform(attributes.transform, adjust)
	end
	if attributes.style then
		use.style = attributes.style
	else
		use.style = {}
	end

	use.tags = tags

	self.__index = self
	setmetatable(use, self)

	use:parseStyles()

	for key,val in ipairs(attributes) do
		if key ~= "style" and key ~= "d" and key ~= "id" then
			use.style[key] = val
		end
	end

	return use

end

function Use:getHref()
	return self.href
end

function Use:tagged(tag)
	for i,val in ipairs(self.tags) do
		if val == tag then
			return true
		end
	end
	return false
end

function Use:parseStyles()
	self.style = utils.parseStyles(self.style)
end

function parseTransform(transform, adjust)
	local newTransform = {}
	print(transform)
	local keyword = string.match(transform, "([^%)]+)%(")
	table.insert(newTransform, keyword)
	for num in string.gmatch(transform, "(-?[%d.]+),?%)?") do
		table.insert(newTransform, tonumber(num) * adjust)
	end
	return newTransform
end

return Use
