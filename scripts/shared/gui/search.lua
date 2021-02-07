function search(searchText)
	local containerItems = world.containerItems(pane.containerEntityId())
	local searchText = string.lower(searchText)
	searchOverlayReset()

	for position, item in pairs(containerItems) do
		local searchMatch = false
		local itemConfig = getItemConfig(item)
		local itemShortdescription = string.lower(itemConfig.shortdescription)
		local itemCategory = itemConfig.category
		local itemColonytag = itemConfig.colonyTags
		local categoryAssociative = root.assetJson("/items/categories.config:labels")

		if string.find(searchText, "^#") then
			local searchText = string.gsub(searchText, "(#)", "")

			-- search by category
			if not searchMatch and itemCategory then
				local category = string.lower(itemCategory)
				if categoryAssociative[itemCategory] then
					category = string.lower(categoryAssociative[itemCategory])
				end
				if string.find(category, searchText) then
					searchMatch = true
				end
			end

			-- search by colony tag
			if not searchMatch and itemColonytag then
				for _, colonytag in pairs(itemColonytag) do
					if string.find(colonytag, searchText) then
						searchMatch = true
						break
					end
				end
			end

		-- search by shortdescription
		elseif string.find(itemShortdescription, searchText) then
			searchMatch = true
		end

		-- search matches
		if searchMatch then
			widget.setVisible("searchfieldOverlay", true)
			-- widget.setVisible("searchOverlay"..position, true)
		else
			widget.setVisible("searchOverlay"..position, true)
		end
	end
end


function searchEnter()
	widget.blur("searchField")
end


function searchAbort()
	searchOverlayReset()
	widget.setText("searchField", "")
	widget.blur("searchField")
end


function searchCallback()
	local searchText = widget.getText("searchField")
	if (not string.find(searchText, "^#") and string.len(searchText) >= 2) or (string.find(searchText, "^#") and string.len(searchText) >= 3) then
		searchActive = true
	else
		searchActive = false
		searchOverlayReset()
	end
end


function searchOverlayReset()
	widget.setVisible("searchfieldOverlay", false)
	local containerSize = world.containerSize(pane.containerEntityId())
	for i = 1, containerSize do
		widget.setVisible("searchOverlay"..i, false)
		widget.setVisible("searchHideOverlay"..i, false)
	end
end
