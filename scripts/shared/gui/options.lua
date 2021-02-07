function initOptions(uiconfigPath)
	toggleOptions = false

	guiColors = {}
	guiColors[1] = "?hueshift=-110?saturation=40?brightness=10" -- red
	guiColors[2] = "?hueshift=-80?saturation=80?brightness=35" -- orange
	guiColors[3] = "?hueshift=-55?saturation=76?brightness=40" -- yellow
	guiColors[5] = "?hueshift=45?saturation=50?brightness=10" -- mint
	guiColors[6] = "?hueshift=65?saturation=65?brightness=20" -- cyan
	guiColors[7] = "?hueshift=88?saturation=50?brightness=14" -- blue
	guiColors[8] = "?hueshift=100?saturation=50?brightness=0" -- darkblue
	guiColors[9] = "?hueshift=155?saturation=20?brightness=15" -- purple
	guiColors[10] = "?hueshift=180?saturation=40?brightness=15" -- pink

	guiColorImages = {}
	guiColorImages['header'] = "backgroundHeader"
	guiColorImages['body'] = "backgroundBody"
	guiColorImages['footer'] = "backgroundFooter"

	-- show header information
	local shortdescription = world.getObjectParameter(pane.containerEntityId(), "shortdescription")
	local categories = root.assetJson("/items/categories.config:labels")
	local category = world.getObjectParameter(pane.containerEntityId(), "category")
	widget.setText("title", "^shadow;^white;"..shortdescription)
	widget.setText("subTitle", "^shadow;^gray;"..(categories[category] or category))

	-- show buttons for supported containers only
	local scripts = world.getObjectParameter(pane.containerEntityId(), "scripts")
	if scripts then
		for k, v in pairs(scripts) do
			if v == "/scripts/enhancedstorage.lua" or v == "/scripts/cropbins.lua" then
				widget.setVisible("transferInventoryItems", true)
				widget.setVisible("sortContainer", true)
				widget.setVisible("optionsButton", true)
				widget.setVisible("searchFieldImage", true)
				widget.setVisible("searchField", true)
			elseif v == "/scripts/liquidtanks.lua" then
				widget.setVisible("transferInventoryItems", true)
				widget.setVisible("sortContainer", true)
				widget.setVisible("optionsButton", true)
			elseif v == "/scripts/capturepodchest.lua" or v == "/scripts/mannequin.lua" then
				widget.setVisible("optionsButton", true)
			end
		end
	end

	-- select checkbox for keepContent
	local keepContent = world.getObjectParameter(pane.containerEntityId(), "keepContent")
	if keepContent == true or keepContent == nil then
		widget.setChecked("keepContent", true)
		keepContent = true
	else
		widget.setChecked("keepContent", false)	
		keepContent = false
	end

	-- select button for interface color
	local slotCount = (uiconfigPath == "/interface/scripted/mannequin/mannequin") and "" or world.getObjectParameter(pane.containerEntityId(), "slotCount")
	local guiColor = world.getObjectParameter(pane.containerEntityId(), "guiColor")
	if guiColor then	
		for k, v in pairs(guiColors) do
			if guiColor == v then
				widget.setSelectedOption("interfaceColors", k)
				for i, j in pairs(guiColorImages) do
					widget.setImage(j, uiconfigPath..slotCount..i..".png"..v)
				end
			end
		end
	else
		widget.setSelectedOption("interfaceColors", 4)
		for i, j in pairs(guiColorImages) do
			widget.setImage(j, uiconfigPath..slotCount..i..".png")
		end
	end

	-- handler
	world.sendEntityMessage(pane.containerEntityId(), "interfaceColors", guiColor)
	world.sendEntityMessage(pane.containerEntityId(), "keepContent", keepContent)
end


function optionsButton()
	toggleOptions = not toggleOptions

	-- disable footer buttons
	widget.setButtonEnabled("sortContainer", not toggleOptions)
	widget.setButtonEnabled("transferInventoryItems", not toggleOptions)

	-- show options menu
	widget.setVisible("optionsBackground", toggleOptions)
	widget.setVisible("optionsLabel", toggleOptions)
	widget.setVisible("optionsSave", toggleOptions)
	widget.setVisible("optionsReset", toggleOptions)
	widget.setVisible("itemGrid", not toggleOptions)
	widget.setVisible("clear", not toggleOptions)
	widget.setVisible("count", not toggleOptions)

	widget.setVisible("optionsOption1Label", toggleOptions)
	widget.setVisible("renameContainer", toggleOptions)
	widget.setVisible("renameContainerEnter", toggleOptions)
	widget.setVisible("renameContainerReset", toggleOptions)
	widget.setVisible("renameContainerImage", toggleOptions)
	widget.setVisible("fontColors", toggleOptions)

	widget.setVisible("optionsOption2Label", toggleOptions)
	widget.setVisible("interfaceColorsBorder", toggleOptions)
	widget.setVisible("interfaceColors", toggleOptions)

	widget.setVisible("optionsOption3Label", toggleOptions)
	widget.setVisible("keepContent", toggleOptions)
end


function optionsSave(reset)
	-- save rename text
	local newName = widget.getText("renameContainer")
	if newName == "reset" then
		world.sendEntityMessage(pane.containerEntityId(), "renameContainer", "")
	elseif newName ~= "" then
		local findColor = string.find(newName, "(^[#%d%a]-;)")
		local findColorEnd = string.find(newName, "(^[#%d%a]-;)$")
		if findColor then
			for w in string.gmatch(newName, "^[#%d%a]-;$") do
				if w ~= "^white;" then
					newName = string.gsub(newName, "("..w..")", "^white;")
				end
			end
			if not findColorEnd then
				newName = newName.."^white;"
			end
		end
		world.sendEntityMessage(pane.containerEntityId(), "renameContainer", newName)
	end

	-- save interface color
	local interfaceColors = widget.getSelectedOption("interfaceColors")
	local guiColor = nil
	for k, v in pairs(guiColors) do
		if interfaceColors == k then
			guiColor = v
		end
	end
	world.sendEntityMessage(pane.containerEntityId(), "interfaceColors", guiColor)

	-- save checkbox
	local keepContent = widget.getChecked("keepContent")
	world.sendEntityMessage(pane.containerEntityId(), "keepContent", keepContent)

	if reset == "reset" then
		world.sendEntityMessage(pane.containerEntityId(), "resetOptions", resetOptions)
	else
		world.sendEntityMessage(pane.containerEntityId(), "saveOptions", saveOptions)
	end

	widget.playSound("/sfx/objects/containerRename.ogg")
	pane.dismiss()
end


function optionsReset()
	widget.setText("renameContainer", "reset")
	widget.setChecked("keepContent", true)
	widget.setSelectedOption("interfaceColors", 4)
	
	optionsSave("reset")
	pane.dismiss()
end


function renameContainer()
	widget.blur("renameContainer")
end


function renameContainerAbort()
	widget.setText("renameContainer", "")
	widget.blur("renameContainer")
end


function fontColors()
	textColors = {}
	textColors[1] = "^white;"
	textColors[2] = "^red;"
	textColors[3] = "^orange;"
	textColors[4] = "^green;"
	textColors[5] = "^blue;"
	textColors[6] = "^#e43774;"

	local selectedFontColor = widget.getSelectedOption("fontColors")
	for k, v in pairs(textColors) do
		local currentText = widget.getText("renameContainer")
		if selectedFontColor == k then
			for w in string.gmatch(currentText, "^[#%d%a]-;$") do
				currentText = string.gsub(currentText, "("..w..")", "")
			end
			widget.setText("renameContainer", currentText..v)
		end
	end
	widget.focus("renameContainer")
end


function interfaceColorsCallback(uiconfigPath)
	local slotCount = (uiconfigPath == "/interface/scripted/mannequin/mannequin") and "" or world.getObjectParameter(pane.containerEntityId(), "slotCount")
	local guiColor = widget.getSelectedOption("interfaceColors")
	for k, v in pairs(guiColors) do
		if guiColor == k then
			for i, j in pairs(guiColorImages) do
				widget.setImage(j, uiconfigPath..slotCount..i..".png"..v)
			end
		elseif guiColor == 4 then
			for i, j in pairs(guiColorImages) do
				widget.setImage(j, uiconfigPath..slotCount..i..".png")
			end
		end
	end
end
