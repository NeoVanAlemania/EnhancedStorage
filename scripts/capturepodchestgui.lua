require("/scripts/shared/gui/denyitem.lua")
require("/scripts/shared/gui/options.lua")

function init()
	--acceptItems = config.getParameter("acceptItems")
	initOptions("/interface/chests/capturepodchest")
end


function update(dt)
	--[[if acceptItems then
		denyInvalidItems(true, false, false)
	end]]

	capturepodImage()
end


function capturepodImage()
	local containerItems = world.containerItems(pane.containerEntityId())
	local containerSize = world.containerSize(pane.containerEntityId())

	-- hide capturepod image
	for i = 1, containerSize do
		widget.setVisible("petImage"..i, false)
  end

	-- set capturepod image
	for slot, item in pairs(containerItems) do
		if item.name == "filledcapturepod" then
			for k, pet in pairs(item.parameters.tooltipFields.objectImage) do
				-- random generated monsters
				if string.find(pet.image, "/generated/") and string.find(pet.image, "/head/") then
					widget.setImage("petImage"..slot, pet.image .. "?flipx")
					widget.setVisible("petImage"..slot, true)
					break

				-- minidrone monsters without head image
				elseif string.find(pet.image, "/minidrone/") and string.find(pet.image, "/body/") then
					widget.setImage("petImage"..slot, pet.image .. "?flipx")
					widget.setVisible("petImage"..slot, true)
					break

				-- unique monsters
				elseif k == 1 then
					widget.setImage("petImage"..slot, pet.image)
					widget.setVisible("petImage"..slot, true)
				end
			end
		end
	end
end


function interfaceColors()
	interfaceColorsCallback("/interface/chests/capturepodchest")
end
