require("/scripts/shared/util.lua")

function init()
	supportedContainers = root.assetJson("/supportedcontainers.config:supportedContainers")
	supportedContainersCache = {}
	itemConfig = {}
	craftTime = world.getObjectParameter(pane.containerEntityId(), "craftTime")

	-- init addons
	addonVersion = root.assetJson("/ES_version.config:addonVersion")
	validSlots = { 9, 12, 16, 24, 32, 40, 48, 56, 64, 72, 80, 90, 100, 110, 120, 130, 140, 150, 160, 180, 200, 300 }
	if addonVersion == "lite" then
		validSlots = { 9, 12, 16, 24, 32, 40, 48, 56, 64 }
	end
end


function update(dt)
	local inputSlot = world.containerItemAt(pane.containerEntityId(), 0)
	local outputSlot = world.containerItemAt(pane.containerEntityId(), 1)
	if startTime then
		timer(inputSlot, outputSlot)
	end

	checkButtonStatus(inputSlot, outputSlot)
end


function timer(inputSlot, outputSlot)
	currentTimer = world.time() - startTime

	-- start progress bar
	if not timerStop then
		widget.setProgress("prgTime", currentTimer / craftTime)

		-- stop progress bar when items differ from initial
		if outputSlot or tableToString(initialInputSlot) ~= tableToString(inputSlot) then
			stopButton()
		end
	end

	-- initiate crafting if time is elapsed
	if currentTimer >= craftTime then
		crafting(inputSlot, outputSlot)
	end

	-- stop crafting process if stop button is pressed or time is elapsed
	if timerStop or currentTimer >= craftTime then
		startTime = nil
		timerStop = true
		currentTimer = 0
		widget.setProgress("prgTime", 0)
		widget.setVisible("craftButton", true)
		widget.setVisible("stopButton", false)
	end
end


function checkButtonStatus(inputSlot, outputSlot)
	craftButtonEnabled = false
	price = 0
	local errorMessage = ""

	-- continue if textbox has text
	local getText = widget.getText("spinnerTextbox")
	if getText ~= "" then
		getText = tonumber(getText)

		-- continue if inputSlot has item
		if inputSlot then

			-- continue if input item is unmodified
			local slotCountParameter = inputSlot.parameters.slotCount
			if not slotCountParameter then

				-- continue if input item is a container and it's empty
				local defaultSlotCount = getItemConfig(inputSlot).slotCount
				if defaultSlotCount and not inputSlot.parameters.content then

					-- continue if input item is supported
					if inputSlot.name == getSupportedContainers(inputSlot.name) then

						-- continue if output slot is empty
						if not outputSlot then

							-- continue if selected slotCount ~= old slotCount
							if defaultSlotCount ~= getText then

								-- continue if selected slotCount a valid number
								for k, v in ipairs(validSlots) do
									if getText == v then
										craftButtonEnabled = true
									end
								end
								errorMessage = not craftButtonEnabled and "^red;- NEW SLOT COUNT is not a valid number -^white;" or ""

								-- calculate price
								local defaultSlotCount = getItemConfig(inputSlot).slotCount
								local deltaSlotCount = math.abs(getText - (inputSlot.parameters.slotCount or defaultSlotCount))
								price = math.ceil(deltaSlotCount * 0.4 * inputSlot.count)
								if (craftButtonEnabled and price > player.hasCountOfItem("enhancedstoragematerial")) then
									craftButtonEnabled = false
									errorMessage = "^red;- you have not enough ingredients -^white;"
								end
							else
								errorMessage = "^red;- NEW SLOT COUNT must be different -^white;"
							end
						else
							errorMessage = "^red;- OUTPUT slot must be empty -^white;"
						end
					else
						errorMessage = "^red;- item not supported -^white;"
					end
				else
					errorMessage = "^red;- INPUT item must be an empty container -^white;"
				end
			else
				errorMessage = "^red;- containers can only be modified once -^white;"
			end
		else
			errorMessage = "^red;- container in INPUT SLOT required -^white;"
		end
	else
		errorMessage = "^red;- NEW SLOT COUNT must be a number -^white;"
	end

	widget.setText("moneyLabel", price)
	widget.setText("lblError", errorMessage)
	widget.setButtonEnabled("craftButton", craftButtonEnabled)
end


function crafting(inputSlot, outputSlot)
	local getText = tonumber(widget.getText("spinnerTextbox"))

	-- spawn new container and demand resource from player
	if inputSlot and not outputSlot then
		-- create outputParameters
		local outputParameters = {
			slotCount = getText,
			shortdescription = getItemConfig(inputSlot).shortdescription .. " ^yellow;^reset;"
		}

		player.consumeItem({ name = "enhancedstoragematerial", count = price, parameters = {} })
		world.containerConsumeAt(pane.containerEntityId(), 0, inputSlot.count)
		world.containerItemApply(pane.containerEntityId(), { name = inputSlot.name, count = inputSlot.count, parameters = outputParameters }, 1)
		widget.playSound("/sfx/interface/craftsuccessful_containermanipulatorstation.ogg")
	else
		widget.playSound("/sfx/interface/clickon_error.ogg")
	end

	enableControls()
end


function spinnerInteraction(operator)
	local getText = tonumber(widget.getText("spinnerTextbox"))
	local lastValidSlot = validSlots[1]
	for k, v in ipairs(validSlots) do

		-- increase or decrease slots for comparing
		if getText == v then 
			getText = ( operator == "add" ) and getText + 1 or getText - 1
		end

		-- is getText between two valid values?
		if getText < v and getText > lastValidSlot then
			return (operator == "add") and v or lastValidSlot

		-- is getText smaller than max valid value?
		elseif getText < validSlots[1] then
			return (operator == "add") and lastValidSlot or validSlots[#validSlots]

		-- is getText bigger than min valid value?
		elseif getText > validSlots[#validSlots] then
			 return (operator == "add") and validSlots[1] or validSlots[#validSlots]
		end

		lastValidSlot = v
	end
end

function craftButton()
	initialInputSlot = world.containerItemAt(pane.containerEntityId(), 0)
	timerStop = false
	startTime = world.time()
	widget.setText("spinnerBlockText", "^#3c3c3c;" .. tonumber(widget.getText("spinnerTextbox")))

	disableControls()
	widget.playSound("/sfx/interface/craft_containermanipulatorstation.ogg")
end

function stopButton()
	initialInputSlot = nil
	timerStop = true

	enableControls()
	widget.playSound("/sfx/interface/clickon_error.ogg")
end

function spinnerTextboxAbort()
	widget.setText("spinnerTextbox", validSlots[1])
	widget.blur("spinnerTextbox")
end

function spinnerTextboxEnter()
	widget.blur("spinnerTextbox")
end

function spinnerPickLeft()
	newText = spinnerInteraction("sub")
	widget.setText("spinnerTextbox", newText)
end

function spinnerPickRight()
	newText = spinnerInteraction("add")
	widget.setText("spinnerTextbox", newText)
end

function enableControls()
	widget.setVisible("itemGrid", true)
	widget.setVisible("outputItemGrid", true)
	widget.setVisible("workingInput", false)
	widget.setVisible("workingOutput", false)

	widget.setVisible("craftButton", true)
	widget.setVisible("stopButton", false)

	widget.setVisible("spinnerTextbox", true)
	widget.setVisible("spinnerBlockText", false)
	widget.setImage("spinnerTextboxImage", "/interface/scripted/containermanipulatorstation/spinnerTextboxImage.png")
	widget.setButtonEnabled("spinnerPickLeft", true)
	widget.setButtonEnabled("spinnerPickRight", true)
end

function disableControls()
	widget.setVisible("itemGrid", false)
	widget.setVisible("outputItemGrid", false)
	widget.setVisible("workingInput", true)
	widget.setVisible("workingOutput", true)

	widget.setVisible("craftButton", false)
	widget.setVisible("stopButton", true)

	widget.setVisible("spinnerTextbox", false)
	widget.setVisible("spinnerBlockText", true)
	widget.setImage("spinnerTextboxImage", "/interface/scripted/containermanipulatorstation/spinnerTextboxBlockImage.png")
	widget.setButtonEnabled("spinnerPickLeft", false)
	widget.setButtonEnabled("spinnerPickRight", false)
end

function getSupportedContainers(objectName)
	if not supportedContainersCache[objectName] then
		for k, v in pairs(supportedContainers) do
			if objectName == k then
				supportedContainersCache[objectName] = k
				break
			end
		end
	end
	return supportedContainersCache[objectName]
end
