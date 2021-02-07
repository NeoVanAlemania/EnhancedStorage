function initSortOptions()
	-- show buttons for supported containers only
	local scripts = world.getObjectParameter(pane.containerEntityId(), "scripts")
	if scripts then
		for k, v in pairs(scripts) do
			if v == "/scripts/enhancedstorage.lua" or v == "/scripts/liquidtanks.lua" then
				local sortPriority = world.getObjectParameter(pane.containerEntityId(), "sortPriority") or "name"
				local sortDirection = world.getObjectParameter(pane.containerEntityId(), "sortDirection") or "ascending"

				if sortDirection == "ascending" then
					widget.setChecked("sortoptionsdirection", true)
				end

				widget.setVisible("sortoptionstab", true)
				widget.setVisible("sortoptionsdirection", true)
				widget.setVisible("sortoptionsby" .. sortPriority, true)
			end
		end
	end
end


function sortContainerCallback()
	world.sendEntityMessage(pane.containerEntityId(), "sortContainer")
end


function sortoptionsdirection()
	local sortDirection = "descending"
	if widget.getChecked("sortoptionsdirection") then
		sortDirection = "ascending"
	end
	world.sendEntityMessage(pane.containerEntityId(), "sortDirection", sortDirection)
end


function sortoptionsbyname()
	widget.setVisible("sortoptionsbyname", false)
	widget.setVisible("sortoptionsbytype", true)
	world.sendEntityMessage(pane.containerEntityId(), "sortPriority", "type")
end


function sortoptionsbytype()
	widget.setVisible("sortoptionsbytype", false)
	widget.setVisible("sortoptionsbyrarity", true)
	world.sendEntityMessage(pane.containerEntityId(), "sortPriority", "rarity")
end


function sortoptionsbyrarity()
	widget.setVisible("sortoptionsbyrarity", false)
	widget.setVisible("sortoptionsbyvalue", true)
	world.sendEntityMessage(pane.containerEntityId(), "sortPriority", "value")
end


function sortoptionsbyvalue()
	widget.setVisible("sortoptionsbyvalue", false)
	widget.setVisible("sortoptionsbyname", true)
	world.sendEntityMessage(pane.containerEntityId(), "sortPriority", "name")
end
