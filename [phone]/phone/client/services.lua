local Services = {}
RegisterNetEvent('qb-phone:client:postedReport')
AddEventHandler('qb-phone:client:postedReport', function(type, job, typejob, message)
    for k, v in each(Services) do
        if type == "single" then
            if v.name == job then
                table.insert(Services[k].messages, message)
                break
            end
        elseif type == "all" then
            if v.typejob == typejob then
                table.insert(Services[k].messages, message)
            end
        end
    end
    if type == "single" then
        if PlayerJob.name == job then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Services",
                    text = "New report".. " " .. message.message,
                    icon = "fas fa-bell",
                    color = "#ff002f",
                    timeout = 6500,
                },
            })
        end
    elseif type == "all" then
        if PlayerJob.typejob == job then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Services",
                    text = "New report".. " " .. message.message,
                    icon = "fas fa-bell",
                    color = "#ff002f",
                    timeout = 6500,
                },
            })
        end
    end
end)

RegisterNUICallback('GetServices', function(data, cb)
    TriggerServerEvent("qb-phone:server:getServices")
    RegisterNetEvent('qb-phone:client:getServices')
    AddEventHandler('qb-phone:client:getServices', function(services)
        Services = services
        cb(Services)
    end)
end)

RegisterNUICallback('GetMessages', function(data, cb)
    if PlayerJob.name then
        for k, v in each(Services) do
            if PlayerJob.name == v.name then
                cb(v.messages)
            end
        end
    else
        cb({})
    end
end)

RegisterNUICallback('PostNewReport', function(data, cb)
    local coords = getLocation()
    SendData = {
        userData = {
            ip = PhoneData.MetaData.ip,
            location = {
                ["x"] = coords.x,
                ["y"] = coords.y,
                ["z"] = coords.z
            },
            player = exports.data:getCharVar('id'),
            phone = PhoneData.MetaData.id,
            telNumber = PhoneData.MetaData.simActive.primary.telNumber or false
        },
        message = data.message
    }
    TriggerServerEvent("qb-phone:server:postNewReport", data.data, SendData)
end)

RegisterNUICallback('AddNewService', function(data, cb)
    TriggerServerEvent("qb-phone:server:setNewServices", data.Job)
end)

RegisterNUICallback('ServiceCall', function(data, cb)
    if data.telNumber then
        SendNUIMessage({
            action = "setupCall",
            cData = {
                name = IsNumberInContacts(tostring(data.telNumber)),
                number = data.telNumber,
            }
        })
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Services",
                text = "There is no tel. number",
                icon = "fas fa-bell",
                color = "#ff002f",
                timeout = 1500,
            },
        })
    end
end)

RegisterNUICallback('SetWP', function(data, cb)
    if data.location.x then
        SetNewWaypoint(data.location.x, data.location.y)
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Services",
                text = "Waypoint was set",
                icon = "fas fa-bell",
                color = "#ff002f",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Services",
                text = "There is no waypoint",
                icon = "fas fa-bell",
                color = "#ff002f",
                timeout = 1500,
            },
        })
    end
end)