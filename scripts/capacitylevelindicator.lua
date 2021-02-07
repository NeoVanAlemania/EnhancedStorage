function init()
	currentChest = ""
	frameOrder = {
		metal = "wood",
		wood = "apex",
		apex = "avian",
		avian = "floran",
		floran = "glitch",
		glitch = "human",
		human = "hylotl",
		hylotl = "novakid",
		novakid = "metal"
	}

	local style = config.getParameter("style") or "metal"
	animator.setAnimationState("indicatorState", style .. "_" .. "off")
end


function getStorageObject()
	currentChest = ""

	if object.name() == "capacitylevelindicator1" then
		searchArea = {
				{-2, 0}, {-1, 1}, {0, 1}, {1, 1}, {2, 0}, {1, -1}, {0, -1}, {-1, -1},
				{-3, 0}, {-2, 1}, {-1, 2}, {0, 2}, {1, 2}, {2, 1}, {3, 0}, {2, -1}, {1, -2}, {0, -2}, {-1, -2}, {-2, -1},
				{-4, 0}, {-3, 1}, {-2, 2}, {-1, 3}, {0, 3}, {1, 3}, {2, 2}, {3, 1}, {4, 0}, {3, -1}, {2, -2}, {1, -3}, {0, -3}, {-1, -3}, {-2, -2}, {-3, -1},
				{-4, 1}, {-3, 2}, {-2, 3}, {2, 3}, {3, 2}, {4, 1}, {4, -1}, {3, -2}, {2, -3}, {-2, -3}, {-3, -2}, {-4, -1},
				{-4, 2}, {-3, 3}, {3, 3}, {4, 2}, {4, -2}, {3, -3}, {-3, -3}, {-4, -2},
				{-4, 3}, {4, 3}, {4, -3}, {-4, -3}
		}
	elseif object.name() == "capacitylevelindicator2" then
		searchArea = {
				{-1, 1}, {-1, 2}, {0, 3}, {1, 2}, {1, 1}, {1, 0}, {0, -1}, {-1, 0},
				{-2, 1}, {-2, 2}, {-1, 3}, {0, 4}, {1, 3}, {2, 2}, {2, 1}, {2, 0}, {1, -1}, {0, -2}, {-1, -1}, {-2, 0},
				{-3, 1}, {-3, 2}, {-2, 3}, {-1, 4}, {0, 5}, {1, 4}, {2, 3}, {3, 2}, {3, 1}, {3, 0}, {2, -1}, {1, -2}, {0, -3}, {-1, -2}, {-2, -1}, {-3, 0},
				{-3, 3}, {-2, 4}, {-1, 5}, {1, 5}, {2, 4}, {3, 3}, {3, -1}, {2, -2}, {1, -3}, {-1, -3}, {-2, -2}, {-3, -1},
				{-3, 4}, {-2, 5}, {2, 5}, {3, 4}, {3, -2}, {2, -3}, {-2, -3}, {-3, -2},
				{-3, 5}, {3, 5}, {3, -3}, {-3, -3}
		}
	else
		searchArea = {
				{-3, 0}, {-3, 1}, {-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 1}, {2, 0}, {1, -1}, {0, -1}, {-1, -1}, {-2, -1},
				{-4, 0}, {-4, 1}, {-3, 2}, {-2, 3}, {-1, 3}, {0, 3}, {1, 3}, {2, 2}, {3, 1}, {3, 0}, {2, -1}, {1, -2}, {0, -2}, {-1, -2}, {-2, -2}, {-3, -1},
				{-5, 0}, {-5, 1}, {-4, 2}, {-3, 3}, {-2, 4}, {-1, 4}, {0, 4}, {1, 4}, {2, 3}, {3, 2}, {4, 1}, {4, 0}, {3, -1}, {2, -2}, {1, -3}, {0, -3}, {-1, -3}, {-2, -3}, {-3, -2}, {-4, -1},
				{-5, 2}, {-4, 3}, {-3, 4}, {2, 4}, {3, 3}, {4, 2}, {4, -1}, {3, -2}, {2, -3}, {-3, -3}, {-4, -2}, {-5, -1},
				{-5, 3}, {-4, 4}, {3, 4}, {4, 3}, {4, -2}, {3, -3},
				{-5, 4}, {4, 4}, {4, -3}, {-5, -3}
		}
	end

	for k, v in ipairs(searchArea) do
		tileX = entity.position()[1] + v[1]
		tileY = entity.position()[2] + v[2]
		entityAtTile = world.objectAt({tileX, tileY})
		if entityAtTile then
			local slotCount = world.getObjectParameter(entityAtTile, "slotCount")
			if slotCount then
				currentChest = entityAtTile
				break
			end
		end
	end
end


function onInteraction()
	setAnimationState()
end


function setAnimationState(imageFrame)
	-- get current used material
	local currentFrameType = animator.animationState("indicatorState")
	local currentMaterial, index = currentFrameType:match("([^,]+)_([^,]+)")
	local material = "metal"

	-- set material on interaction
	if imageFrame == nil then
		for k, v in pairs(frameOrder) do
			if currentMaterial == k then
				material = v
				imageFrame = index
				object.say("Style:\n" .. string.gsub(" "..material, "%W%l", string.upper):sub(2))
				break
			end
		end
	else
		-- set material on update
		material = currentMaterial
	end

	object.setConfigParameter("style", material)
	animator.setAnimationState("indicatorState", material .. "_" .. imageFrame)
end


function update(dt)
	local imageFrame = "off"

	-- chest in range
	if currentChest ~= "" and currentChest ~= nil then
		local slotCountMax = world.containerSize(currentChest)
		if world.entityExists(currentChest) and slotCountMax ~= nil and slotCountMax > 0 then
			local content = world.containerItems(currentChest)
			local animationFrames = config.getParameter("animationFrames")
			local slotCount = 0
			imageFrame = 0
	
			-- get used slots from chest
			if next(content) ~= nil then
				for position, item in pairs(content) do
					slotCount = slotCount + 1
				end
			end

			-- calculate appropriate image frame
			imageFrame = math.ceil((slotCount / slotCountMax) * animationFrames)
			if imageFrame == animationFrames and slotCount < slotCountMax then
				imageFrame = animationFrames - 1
			end
		else
			currentChest = ""
		end
	else
		-- search for chest
		getStorageObject()
	end

	setAnimationState(imageFrame)
end
