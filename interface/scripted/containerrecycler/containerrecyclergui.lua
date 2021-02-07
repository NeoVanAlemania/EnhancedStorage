require("/scripts/shared/util.lua")

function init()
	itemConfig = {}
	craftTime = world.getObjectParameter(pane.containerEntityId(), "craftTime") or 2
end


function update(dt)
	currentTime = world.getObjectParameter(pane.containerEntityId(), "currentTime") or 0
	widget.setProgress("prgTime", currentTime / craftTime)

	denyInvalidItems()
end


function denyInvalidItems()
	-- check for items in input slots
	local containerSize = world.getObjectParameter(pane.containerEntityId(), "slotCount")
	for i = 0, containerSize - 2 do
		validItem = false
		local itemAtSlot = world.containerItemAt(pane.containerEntityId(), i)
		if itemAtSlot then

			-- set proper item to valid item 
			local slotCount = getItemConfig(itemAtSlot).slotCount
			if slotCount and not itemAtSlot.parameters.content then
				validItem = true
				break
			end

			-- give back invalid items
			if not validItem then
				world.containerConsume(pane.containerEntityId(), itemAtSlot)
				player.giveItem(itemAtSlot)
			end
		end
	end
end
