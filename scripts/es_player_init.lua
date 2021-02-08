local origInit = init
local origUpdate = update

function init(...)
	if origInit then
		origInit(...)
	end
	player.setUniverseFlag("outpost_enhancedstorage")
	local chest9=root.assetJson("/interface/chests/chest9.config")
	if type(chest9.scripts)=="table" then
		local valid=false
		for _,scr in pairs(chest9.scripts) do
			if scr=="/scripts/enhancedstoragegui.lua" then
				valid=true
				break
			end
		end
		if not valid then
			idiotCheckFailed=true
		end
	end
end

function update(...)
	if origUpdate then
		origUpdate(...)
	end
	if idiotCheckFailed then
		if world.entityExists(entity.id()) then
			world.sendEntityMessage(entity.id(),"queueRadioMessage","enhancedstorageincompatiblemod")
			idiotCheckFailed=false
		end
	end
end