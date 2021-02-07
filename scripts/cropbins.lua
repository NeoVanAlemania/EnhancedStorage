require("/scripts/shared/util.lua")
require("/scripts/shared/objects/keepcontent.lua")
require("/scripts/shared/objects/features.lua")
require("/scripts/shared/objects/sortcontainer.lua")

function init()
	itemConfig = {}
	initContainer()

	-- force to load proper uiConfig
	if config.getParameter("uiConfig") then
		object.setConfigParameter("uiConfig", "/interface/chests/chest<slots>.config")
	end
end


function update(dt)
	binInventoryChange()
	placeItems()
end


function die()
	smashContainer("container")
end
