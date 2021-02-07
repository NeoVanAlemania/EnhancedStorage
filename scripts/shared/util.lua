function getItemConfig(itemDesc)
	if not itemDesc then
		return
	elseif type(itemDesc) ~= "table" then
		itemDesc = {name = itemDesc, count = 1, parameters = {}}
	end
	if not itemConfig[itemDesc.name] then
		local default = root.itemConfig(itemDesc)
		-- sb.logInfo("itemConfig: %s", default)
		if default then
			itemConfig[itemDesc.name] = {
				category = default.config.category,
				craftTime = default.config.craftTime,
				inventoryIcon = default.config.inventoryIcon,
				maxStack = default.config.maxStack or root.assetJson("/items/defaultParameters.config:defaultMaxStack"),
				price = default.config.price or 0,
				rarity = default.config.rarity,
				shortdescription = default.config.shortdescription,
				slotCount = default.config.slotCount,
				colonyTags = default.config.colonyTags
			}
		else
			itemConfig[itemDesc.name] = {}
		end
	end

	return itemConfig[itemDesc.name]
end


function tableToString(tbl)
	if type(tbl) == "table" then
		local contents = {}
		for k,v in pairs(tbl) do
			local kstr = tostring(k)
			local vstr = tostring(v)
			if type(v) == "table" and (not getmetatable(v) or not getmetatable(v).__tostring) then
				vstr = tableToString(v)
			end
			contents[#contents+1] = kstr.." = "..vstr
		end
		return "{ " .. table.concat(contents, ", ") .. " }"
	else
		return "{}"
	end
end
