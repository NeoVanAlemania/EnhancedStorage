function sortPriority(msg, something, sortPriority)
	object.setConfigParameter("sortPriority", sortPriority)
end


function sortDirection(msg, something, sortDirection)
	object.setConfigParameter("sortDirection", sortDirection)
end


function sortContainer()
	local sortPriority = config.getParameter("sortPriority") or "name"
	local sortDirection = config.getParameter("sortDirection") or "ascending"
	local content = world.containerItems(entity.id())
	local quality = { other = 0, common = 1, uncommon = 2, rare = 3, legendary = 4, essential = 5 }
	local contentSorted = {}

	-- create new table for sorting
	if content then
		for position, item in pairs(content) do
			local itemConfig = getItemConfig(item)

			local categories = root.assetJson("/items/categories.config:labels")
			local category = itemConfig.category or "other"
			local itemCategory = string.lower(categories[category] or category)
			
			local itemPrice = item.parameters.price or itemConfig.price or 0

			local itemRarity = (itemConfig.rarity and string.lower(itemConfig.rarity)) or "other"
			local itemRottime = item.parameters.timeToRot or 0
			local itemShortdescription = item['parameters']['shortdescription'] or (itemConfig.shortdescription and string.lower(itemConfig.shortdescription))

			local uncoloredShortdescription = string.gsub(itemShortdescription, "(^.-;)", "")
			if uncoloredShortdescription then
				itemShortdescription = uncoloredShortdescription
			end

			table.insert(contentSorted, {name = item.name, count = item.count, parameters = item.parameters, rarity = itemRarity, price = itemPrice, category = itemCategory, shortdescription = itemShortdescription, rottime = itemRottime})
		end
	end

	-- sort by rarity
	local function tableSortRarity(a, b)
		if sortDirection == "ascending" then
			if (quality[a.rarity] < quality[b.rarity]) then return true
				elseif (quality[a.rarity] > quality[b.rarity]) then return false
			end
		else 
			if (quality[a.rarity] > quality[b.rarity]) then return true
				elseif (quality[a.rarity] < quality[b.rarity]) then return false
			end
		end
		if (a.category < b.category) then return true
			elseif (a.category > b.category) then return false
			elseif (a.shortdescription < b.shortdescription) then return true
			elseif (a.shortdescription > b.shortdescription) then return false
			elseif (a.rottime > b.rottime) then return true
			elseif (a.rottime < b.rottime) then return false
			else return a.count > b.count
		end
	end
	
	-- sort by sell value
	local function tableSortValue(a, b)
		if sortDirection == "ascending" then
			if (a.price < b.price) then return true
				elseif (a.price > b.price) then return false
			end
		else
			if (a.price > b.price) then return true
				elseif (a.price < b.price) then return false
			end
		end
		if (quality[a.rarity] > quality[b.rarity]) then return true
			elseif (quality[a.rarity] < quality[b.rarity]) then return false
			elseif (a.shortdescription < b.shortdescription) then return true
			elseif (a.shortdescription > b.shortdescription) then return false
			elseif (a.rottime > b.rottime) then return true
			elseif (a.rottime < b.rottime) then return false
			else return a.count > b.count
		end
	end

	-- sort by category
	local function tableSortCategory(a, b)
		if sortDirection == "ascending" then
			if (a.category < b.category) then return true
				elseif (a.category > b.category) then return false
			end
		else 
			if (a.category > b.category) then return true
				elseif (a.category < b.category) then return false
			end
		end
		if (quality[a.rarity] > quality[b.rarity]) then return true
			elseif (quality[a.rarity] < quality[b.rarity]) then return false
			elseif (a.shortdescription < b.shortdescription) then return true
			elseif (a.shortdescription > b.shortdescription) then return false
			elseif (a.rottime > b.rottime) then return true
			elseif (a.rottime < b.rottime) then return false
			else return a.count > b.count
		end
	end

	-- sort by shortdescription
	local function tableSortShortdescription(a, b)
		if sortDirection == "ascending" then
			if (a.shortdescription < b.shortdescription) then return true
				elseif (a.shortdescription > b.shortdescription) then return false
			end
		else 
			if (a.shortdescription > b.shortdescription) then return true
				elseif (a.shortdescription < b.shortdescription) then return false
			end
		end
		if (quality[a.rarity] > quality[b.rarity]) then return true
			elseif (quality[a.rarity] < quality[b.rarity]) then return false
			elseif (a.category < b.category) then return true
			elseif (a.category > b.category) then return false
			elseif (a.rottime > b.rottime) then return true
			elseif (a.rottime < b.rottime) then return false
			else return a.count > b.count
		end
	end

	if sortPriority == "rarity" then table.sort( contentSorted, tableSortRarity)
		elseif sortPriority == "value" then table.sort( contentSorted, tableSortValue)
		elseif sortPriority == "type" then table.sort( contentSorted, tableSortCategory)
		elseif sortPriority == "name" then table.sort( contentSorted, tableSortShortdescription)
	end
	world.containerTakeAll(entity.id())

	-- put items at new position
	for position, item in pairs (contentSorted) do
		world.containerStackItems(entity.id(), item, position-1)
	end
end
