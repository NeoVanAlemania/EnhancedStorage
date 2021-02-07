require "/scripts/vec2.lua"

function init()
  self.launchDuration = config.getParameter("launchDuration")
  self.launchTiming = config.getParameter("launchTiming")
  self.launchPosition = vec2.add(config.getParameter("launchPosition"), entity.position())

  animator.setAnimationState("shipper", "ready")
  message.setHandler("triggerShipment", startLaunch)
end


function update(dt)
  if self.launchTimer then
    self.launchTimer = self.launchTimer + dt
    if not self.hasLaunched and self.launchTimer >= self.launchTiming then
      self.hasLaunched = true
    end
    if self.launchTimer >= self.launchDuration then
      self.launchTimer = nil
      animator.setAnimationState("shipper", "open")
    end
  end

  object.setInteractive(not self.launchTimer)
end


function startLaunch()
  self.hasLaunched = false
  self.launchTimer = 0
  animator.setAnimationState("shipper", "ship")

  object.setInteractive(false)
  world.containerTakeAll(entity.id())
end


function valueOfContents()
  local value = 0
  local allItems = world.containerItems(entity.id())
  for _, item in pairs(allItems) do
    value = value + (self.itemValues[item.name] or 0) * item.count
  end
  return value
end
