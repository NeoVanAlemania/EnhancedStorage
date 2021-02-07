function buildGatherItemWithParametersCondition(config)
  local gatherItemWithSlotCountCondition = {
    description = config.description or root.assetJson("/quests/quests.config:objectiveDescriptions.gatherItem"),
    itemName = config.itemName,
    count = config.count or 1,
    consume = config.consume or false,
		parameters = buildParameters(config)
  }

  function gatherItemWithSlotCountCondition:conditionMet()
    return player.hasItem({ name = self.itemName, count = self.count, parameters = self.parameters })
  end

  function gatherItemWithSlotCountCondition:onQuestComplete()
    if self.consume then
      player.consumeItem({ name = self.itemName, count = self.count, parameters = self.parameters })
    end
  end

  function gatherItemWithSlotCountCondition:objectiveText()
    local objective = self.description

    objective = objective:gsub("<itemName>", root.itemConfig(self.itemName).config.shortdescription or self.itemName)
    objective = objective:gsub("<required>", self.count)
    objective = objective:gsub("<current>", player.hasCountOfItem({ name = self.itemName, count = self.count, parameters = self.parameters }) or 0)
    return objective
  end

  return gatherItemWithSlotCountCondition
end


function buildParameters(config)
	local shortdescription = root.itemConfig(config.itemName).config.shortdescription
	local slotCount = config.slotCount

	if config.modified then
		shortdescription = shortdescription .. " ^yellow;^reset;"
	end

	local parameters = { slotCount = slotCount, shortdescription = shortdescription }
	return parameters
end
