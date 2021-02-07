function transferInventoryItems()
	local containerItems = world.containerItems(pane.containerEntityId())
	if not containerItems then
		if world.entityExists(pane.containerEntityId()) then
			world.sendEntityMessage(pane.containerEntityId(), "stackingCanceled", "No items apparently?")
		end
		return
	end
	
	local containerSize = world.containerSize(pane.containerEntityId())
	if not containerSize then
		if world.entityExists(pane.containerEntityId()) then
			world.sendEntityMessage(pane.containerEntityId(), "stackingCanceled", "Not a container maybe?")
		end
		return
	end
	
	local equippedItems = getListEquippedItems()
	local transferCanceled = {}
	local containerFreeSlots = {}
	local calc = {}

	for i=0, containerSize-1 do
		local containerItemAtSlot = world.containerItemAt(pane.containerEntityId(), i)

		if not containerItemAtSlot then
			table.insert(containerFreeSlots, i)
		else
			local amount = player.hasCountOfItem(containerItemAtSlot, true)
			local itemConfig = getItemConfig(containerItemAtSlot)
			local maxStack = (itemConfig.category and itemConfig.category == "Blueprint" and 1) or itemConfig.maxStack
			local missing = maxStack - containerItemAtSlot.count

			-- if item is money or container do not continue
			if containerItemAtSlot.name ~= "money" then
				if not equippedItems[containerItemAtSlot.name] then
					if missing > 0 and amount > 0 then
						calc[i] = world.containerItemAt(pane.containerEntityId(), i)
						local consume = math.min(missing, amount)
						containerItemAtSlot.count = consume
						local attempt = player.consumeItem(containerItemAtSlot, true, true)
						if attempt and attempt.count == containerItemAtSlot.count then
							calc[i].count = calc[i].count + consume
							world.containerItemApply(pane.containerEntityId(), calc[i], i)
						else
							sb.logError("[ES] Unable to consume: %s | %s", amount, containerItemAtSlot)
						end
					end
				else
					-- fill list with non-transferable items
					if not transferCanceled[shortdescription] then
						local shortdescription = getItemConfig(containerItemAtSlot).shortdescription
						transferCanceled[shortdescription] = true
					end
				end
			end
		end
	end

	if #containerFreeSlots > 0 then
		for k, item in pairs(containerItems) do
			local itemConfig = getItemConfig(item)

			-- if item is money or container do not continue
			if item.name ~= "money" then
				if not equippedItems[item.name] then
					while #containerFreeSlots > 0 and player.hasCountOfItem(item, true) > 0 do
						local amount = player.hasCountOfItem(item, true)
						local maxStack = itemConfig.maxStack
						local consume = math.min(amount, maxStack)
						item.count = consume
						local attempt = player.consumeItem(item, true, true)
						if attempt and attempt.count == item.count then
							world.containerItemApply(pane.containerEntityId(), item, containerFreeSlots[1])
							calc[containerFreeSlots[1]] = item
							table.remove(containerFreeSlots, 1)
						else
							sb.logError("[ES] Unable to consume: %s | %s", amount, item)
						end
					end
				else
					-- fill list with non-transferable items
					if not transferCanceled[shortdescription] then
						local shortdescription = getItemConfig(item).shortdescription
						transferCanceled[shortdescription] = true
					end
				end
			end
		end
	end

	local outputList = {}
	for k, v in pairs(transferCanceled) do
		table.insert(outputList, k)
	end
	if next(outputList) ~= nil then
		local equippedItemsText = "Equipped items could\n not be transfered: \n\n"..table.concat(outputList, ", ")
		world.sendEntityMessage(pane.containerEntityId(), "stackingCanceled", equippedItemsText)
	end
end


function getListEquippedItems ()
	local equippedItems = {}
	local equipSlots = { "head", "chest", "legs", "back", "headCosmetic", "chestCosmetic", "legsCosmetic", "backCosmetic"}

	for k, v in pairs(equipSlots) do
		if player.equippedItem(v) then
			equippedItems[player.equippedItem(v).name] = true
		end
	end
	if player.primaryHandItem() then equippedItems[player.primaryHandItem().name] = true end
	if player.altHandItem() then equippedItems[player.altHandItem().name] = true end

	return equippedItems
end
