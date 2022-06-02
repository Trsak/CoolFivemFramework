RegisterCommand("pzcreate", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    local zoneType = args[1]
    if zoneType == nil then
      TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Me", "Please add zone type to create (poly, circle, box)!"}
      })
      return
    end
    if zoneType ~= 'poly' and zoneType ~= 'circle' and zoneType ~= 'box' then
      TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Me", "Zone type must be one of: poly, circle, box"}
      })
      return
    end
    local name = nil
    if #args >= 2 then name = args[2]
    else name = GetUserInput("Enter name of zone:") end
    if name == nil or name == "" then
      TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Me", "Please add a name!"}
      })
      return
    end
    TriggerEvent("polyzone:pzcreate", zoneType, name, args)
  end
end)

RegisterCommand("pzadd", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzadd")
  end
end)

RegisterCommand("pzundo", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzundo")
  end
end)

RegisterCommand("pzfinish", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzfinish")
  end
end)

RegisterCommand("pzlast", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzlast")
  end
end)

RegisterCommand("pzcancel", function(src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzcancel")
  end
end)

RegisterCommand("pzcomboinfo", function (src, args)
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent("polyzone:pzcomboinfo")
  end
end)

Citizen.CreateThread(function()
  while not exports.data:isUserLoaded() do
      Citizen.Wait(500)
  end
  
  if exports.data:getUserVar("admin") >= 3 then 
    TriggerEvent('chat:addSuggestion', '/pzcreate', 'Starts creation of a zone for PolyZone of one of the available types: circle, box, poly', {
      {name="zoneType", help="Zone Type (required)"},
    })

    TriggerEvent('chat:addSuggestion', '/pzadd', 'Adds point to zone.', {})
    TriggerEvent('chat:addSuggestion', '/pzundo', 'Undoes the last point added.', {})
    TriggerEvent('chat:addSuggestion', '/pzfinish', 'Finishes and prints zone.', {})
    TriggerEvent('chat:addSuggestion', '/pzlast', 'Starts creation of the last zone you finished (only works on BoxZone and CircleZone)', {})
    TriggerEvent('chat:addSuggestion', '/pzcancel', 'Cancel zone creation.', {})
    TriggerEvent('chat:addSuggestion', '/pzcomboinfo', 'Prints some useful info for all created ComboZones', {})
  end
end)