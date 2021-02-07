require("/scripts/shared/util.lua")
require("/scripts/shared/gui/denyitem.lua")

function init()
	itemConfig = {}
	acceptItems = config.getParameter("acceptItems")
	acceptCategories = config.getParameter("acceptCategories")
end


function update(dt)
  widget.setText("lblMoney", valueOfContents())
end


function triggerShipment(widgetName, widgetData)
  world.sendEntityMessage(pane.containerEntityId(), "triggerShipment")
  local total = valueOfContents()
  if total > 0 then
    player.giveItem({name = "money", count = total})
  end
  pane.dismiss()
end


function valueOfContents()
	local sellFactor = config.getParameter("sellFactor")
	local value = 0

	local validItemList = denyInvalidItems(true, true, false)
	for _, item in pairs(validItemList) do
		local getPrice = item.parameters.price or getItemConfig(item).price or 0
		value = value + math.ceil(getPrice * item.count * sellFactor)
	end

  return value
end
