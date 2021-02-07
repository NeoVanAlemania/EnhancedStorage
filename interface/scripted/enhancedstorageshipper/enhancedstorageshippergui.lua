require("/scripts/shared/util.lua")

function init()
	itemConfig = {}
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
  local allItems = widget.itemGridItems("itemGrid")
	local sellFactor = config.getParameter("sellFactor")
	local value = 0
	local getPrice = 0
  for _, item in pairs(allItems) do
		getPrice = item.parameters.price or getItemConfig(item).price or 0
		value = value + math.ceil(getPrice * item.count * sellFactor)
  end
  return value
end
