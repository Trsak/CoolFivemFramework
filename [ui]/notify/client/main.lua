function display(data)
    SendNUIMessage({action = "message", style = data.type, title = data.title, text = data.text, icon = data.icon, length = data.length})
end

function outlawAlert(data)
    SendNUIMessage(
        {
            action = "outlaw",
            style = data.type,
            title = data.title,
            code = data.code,
            location = data.location,
            weapon = data.weapon,
            icon = data.icon,
            length = data.length,
            vehicle = data.vehicle,
            plate = data.plate,
            color = data.color
        }
    )
end

RegisterNetEvent('notify:display')
AddEventHandler('notify:display', function(data)
    display(data)
end)