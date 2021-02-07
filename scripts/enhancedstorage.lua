local enhancedstorageoldinit=init
local enhancedstorageoldupdate=update
local enhancedstorageolddie=die

require("/scripts/shared/util.lua")
require("/scripts/shared/objects/keepcontent.lua")
require("/scripts/shared/objects/features.lua")
require("/scripts/shared/objects/sortcontainer.lua")

function init()
	if enhancedstorageoldinit then enhancedstorageoldinit() end
	itemConfig = {}
	initContainer()

	-- force to load proper uiConfig
	if config.getParameter("uiConfig") then
		object.setConfigParameter("uiConfig", "/interface/chests/chest<slots>.config")
	end
end

function update(dt)
	if enhancedstorageoldupdate then enhancedstorageoldupdate(dt) end
	placeItems()
end

function die()
	if enhancedstorageolddie then enhancedstorageolddie() end
	smashContainer("container")
end
