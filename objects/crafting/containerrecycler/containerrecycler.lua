require("/scripts/shared/util.lua")

function init()
	itemConfig = {}
	currentTime = 0
	timerActive = false
	craftTime = config.getParameter("craftTime")
	containerSize = config.getParameter("slotCount")
end


function update(dt)
	if not timerActive and next(world.containerItems(entity.id())) ~= nil then

		-- continue if output slot is empty or has enhancedstoragematerial
		local outputSlot = world.containerItemAt(entity.id(), containerSize - 1)
		local maxStack = getItemConfig("enhancedstoragematerialfragment").maxStack
		if not outputSlot or (outputSlot.name == "enhancedstoragematerialfragment" and outputSlot.count < maxStack) then

			-- look for items in input slots
			for i = 0, containerSize - 2 do
				local itemAtSlot = world.containerItemAt(entity.id(), i)
				if itemAtSlot then
					if checkItem(itemAtSlot) then
						timerActive = true
						startTime = world.time()
						animator.setAnimationState("recyclerState", "active")
						consumeItemAt = i
						break
					end
				end
			end
		end
	end

	if timerActive then
		timer()
	end
end


function timer()
	if currentTime < craftTime then
		currentTime = world.time() - startTime

		-- cancel if input item is no longer present
		if not world.containerItemAt(entity.id(), consumeItemAt) then
			stopTimer()
		end

	-- start crafting
	else
		stopTimer()
		crafting()
	end
	object.setConfigParameter("currentTime", currentTime)
end


function checkItem(item)
	local slotCount = getItemConfig(item).slotCount
	if slotCount and not item.parameters.content then
		return true
	end
end


function crafting()
	local inputSlot = world.containerItemAt(entity.id(), consumeItemAt)
	local outputSlot = world.containerItemAt(entity.id(), containerSize - 1)
	local maxStack = getItemConfig("enhancedstoragematerialfragment").maxStack
	if inputSlot and (not outputSlot or (outputSlot.name == "enhancedstoragematerialfragment" and outputSlot.count < maxStack)) then

		-- randomize output count
		local outputCount = 1
		local randomNumber = math.random()
		if randomNumber <= 0.1 then
				outputCount = 3
		elseif randomNumber <= 0.5 then
				outputCount = 2
		end

		-- consume item and generate output
		world.containerConsumeAt(entity.id(), consumeItemAt, 1)
		world.containerPutItemsAt(entity.id(), { name = "enhancedstoragematerialfragment", count = outputCount, parameters = {} }, containerSize - 1)
		consumeItemAt = nil
	end
end


function stopTimer()
	currentTime = 0
	timerActive = false
	animator.setAnimationState("recyclerState", "idle")
end
