function denyInvalidItems(checkName, checkCategory, checkType)
	local validItemList = {}
	local containerItems = world.containerItems(pane.containerEntityId()) or {}
	for _, containerItem in pairs(containerItems) do
		validItem = false

		-- item name
		if checkName and not validItem then
			for _, acceptItem in pairs(acceptItems) do
				if containerItem.name == acceptItem then
					validItem = true
					break
				end
			end
		end

		-- item category
		if checkCategory and not validItem then
			for _, acceptCategory in pairs(acceptCategories) do
				local getCategory = getItemConfig(containerItem).category
				if getCategory == acceptCategory then
					validItem = true
					break
				end
			end
		end

		-- item type
		if checkType and not validItem then
			for _, acceptType in pairs(acceptTypes) do
				local containerItemType = root.itemType(containerItem.name)
				if containerItemType == acceptType then
					validItem = true
					break
				end
			end
		end

		-- give back invalid items
		if not validItem then
			if world.containerConsume(pane.containerEntityId(), containerItem) then
				player.giveItem(containerItem)
			end
		else
			table.insert(validItemList, containerItem)
		end
	end

	return validItemList
end
