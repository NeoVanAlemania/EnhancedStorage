require("/scripts/shared/util.lua")
require("/scripts/shared/gui/denyitem.lua")
require("/scripts/shared/gui/options.lua")
require("/scripts/shared/gui/search.lua")
require("/scripts/shared/gui/quickstack.lua")
require("/scripts/shared/gui/sortoptions.lua")

function init()
	itemConfig = {}
	acceptItems = config.getParameter("acceptItems")
	initOptions("/interface/chests/chest")
	initSortOptions()
	searchActive = false
end


function update(dt)
	if acceptItems then
		denyInvalidItems(true, false, false)
	end

	-- execute search while typing
	if searchActive then
		local searchText = widget.getText("searchField")
		search(searchText)
	end
end


function interfaceColors()
	interfaceColorsCallback("/interface/chests/chest")
end
