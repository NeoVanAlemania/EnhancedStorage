local origInit = init

function init(...)
	if origInit then
		origInit(...)
	end
	player.setUniverseFlag("outpost_enhancedstorage")
end
