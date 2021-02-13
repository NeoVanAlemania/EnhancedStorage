require("/scripts/shared/util.lua")
require("/scripts/shared/objects/keepcontent.lua")
require("/scripts/shared/objects/features.lua")
require("/scripts/shared/objects/sortcontainer.lua")
require("/scripts/shared/objects/liquids.lua")

function init()
	itemConfig = {}
	initContainer()
	initLiquids()

	liquidContainerActive = false
	currentLiquid = ""

	-- force to load proper uiConfig
	if config.getParameter("uiConfig") then
		object.setConfigParameter("uiConfig", "/interface/scripted/liquidtanks/liquidtank<slots>.config")
	end
end


function update(dt)
	placeItems()

	if not liquidContainerActive then
		setAnimationState()
	end
end


function setAnimationState()
	liquidContainerActive = true

	-- local currentLiquidCount = 0
	local imageType = "liquidwater"
	local imageFrame = 1

	-- get current liquid
	local content = world.containerItems(entity.id())
	if next(content) ~= nil then
		currentLiquid=""
		object.setLightColor({0, 0, 0})
		for _, item in pairs(content) do
			local iConf=root.itemConfig(item)
			if iConf.parameters.liquid or iConf.config.liquid then
				local liqName=iConf.parameters.liquid or iConf.config.liquid
				local liqConfig=root.liquidConfig(liqName)
				liqConfig=liqConfig.config or nil
				if liqConfig then
					currentLiquid = item.name
					--sb.logInfo("liqConfig: %s",liqConfig)
					local color=liqConfig.radiantLight or liqConfig.color or {0,0,0}
					object.setLightColor(color)
					-- set light color for current liquid
					--[[if liquidTypes[item.name] and next(liquidTypes[item.name]) ~= nil then
						object.setLightColor(liquidTypes[item.name])
					end]]
					break
				end
			end
		end
	else
		currentLiquid = ""
		object.setLightColor({0, 0, 0})
	end

	-- set animation state
	if currentLiquid ~= "" then
		local currentLiquidCount = world.containerAvailable(entity.id(), currentLiquid)
		local maxStack = getItemConfig(currentLiquid).maxStack
		local maxCount = world.getObjectParameter(entity.id(), "slotCount") * math.min(1000, maxStack)

		if currentLiquidCount > maxCount then
			currentLiquidCount = maxCount
		end

		if not animationFrames then animationFrames = world.getObjectParameter(entity.id(), "animationFrames") end
		imageFrame = math.ceil((currentLiquidCount / maxCount) * animationFrames)
		if imageFrame < 2 then
			imageFrame = 2
		elseif imageFrame == animationFrames and currentLiquidCount < maxCount then
			imageFrame = animationFrames - 1
		end

		if liquidTypes[currentLiquid] then
			imageType = currentLiquid
		end
	end
	animator.setAnimationState("tankState", imageType..imageFrame)

	liquidContainerActive = false
end


function die()
	smashContainer("liquidtank")
end
