require("/scripts/shared/util.lua")
require("/scripts/shared/objects/keepcontent.lua")
require("/scripts/shared/objects/features.lua")

function init()
	itemConfig = {}
	initContainer()
end


function update(dt)
	placeItems()
end


function die()
	smashContainer("capturepodchest")
end
