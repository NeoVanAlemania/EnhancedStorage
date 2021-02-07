require("/scripts/shared/util.lua")
require("/scripts/shared/gui/options.lua")
require("/scripts/shared/gui/quickstack.lua")

function init()
	itemConfig = {}
	initOptions("/interface/chests/chest")

	liquidContainerActive = false
	currentLiquid = ""
end


function update(dt)
	if not liquidContainerActive then
		liquidContainer()
	end
end


function liquidContainer()
	liquidContainerActive = true

	-- set current liquid
	local content = world.containerItems(pane.containerEntityId())
	if next(content) ~= nil then
		for k, item in pairs(content) do
			if currentLiquid == "" then
				if root.itemType(item.name) == "liquid" then
					currentLiquid = item.name
				end
			end
			-- give player invalid items back
			if currentLiquid ~= item.name then
				world.containerConsume(pane.containerEntityId(), item)
				player.giveItem(item)
			end
		end
	else
		currentLiquid = ""
	end

	liquidContainerActive = false
end


function interfaceColors()
	interfaceColorsCallback("/interface/chests/chest")
end
